import Combine
import Foundation

@MainActor
final class AppModel: ObservableObject {
    @Published private(set) var isAuthenticated: Bool
    @Published private(set) var isConnecting = false
    @Published private(set) var isRefreshing = false
    @Published private(set) var user: VercelUser?
    @Published private(set) var teams: [VercelTeam] = []
    @Published private(set) var projects: [VercelProject] = []
    @Published private(set) var recentDeployments: [VercelDeployment] = []
    @Published private(set) var scopeID: String
    @Published var errorMessage: String?

    private var api: VercelAPI?
    private var hasBootstrapped = false
    private var refreshGeneration: UInt = 0
    private static let scopeKey = "vercelmanager.scopeID"

    init() {
        let token = KeychainStore.read()
        self.api = token.map(VercelAPI.init)
        self.isAuthenticated = token != nil
        self.scopeID = UserDefaults.standard.string(forKey: Self.scopeKey) ?? ""
    }

    var activeTeamID: String? {
        scopeID.isEmpty ? nil : scopeID
    }

    var accountLabel: String {
        teams.first(where: { $0.id == scopeID })?.name ?? "Persönlicher Account"
    }

    func bootstrap() async {
        guard !hasBootstrapped else { return }
        hasBootstrapped = true
        guard let api else { return }

        do {
            user = try await api.user()
            teams = (try? await api.teams()) ?? []
            reconcileScopeWithTeams()
        } catch {
            if handleUnauthorizedIfNeeded(error) { return }
            errorMessage = NetworkUserMessage.text(for: error)
        }
        guard isAuthenticated else { return }
        await refresh()
    }

    func signIn(with rawToken: String) async {
        let token = rawToken.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !token.isEmpty else {
            errorMessage = "Bitte einen Vercel-Token eingeben."
            return
        }

        isConnecting = true
        errorMessage = nil
        defer { isConnecting = false }

        do {
            let client = VercelAPI(token: token)
            let verifiedUser = try await client.user()
            try KeychainStore.save(token)

            api = client
            user = verifiedUser
            teams = (try? await client.teams()) ?? []
            reconcileScopeWithTeams()
            isAuthenticated = true
            await refresh()
        } catch {
            if handleUnauthorizedIfNeeded(error) { return }
            errorMessage = NetworkUserMessage.text(for: error)
        }
    }

    func refresh() async {
        guard let api else { return }
        refreshGeneration &+= 1

        while true {
            let generation = refreshGeneration
            let scopeAtStart = scopeID
            let teamIDAtStart = activeTeamID
            isRefreshing = true
            errorMessage = nil

            do {
                async let loadedProjects = api.projects(teamID: teamIDAtStart)
                async let loadedDeployments = api.deployments(teamID: teamIDAtStart)

                let fetchedProjects = try await loadedProjects
                let fetchedDeployments = try await loadedDeployments

                guard RefreshCoordinator.shouldApply(
                    requestGeneration: generation,
                    currentGeneration: refreshGeneration,
                    scopeAtStart: scopeAtStart,
                    currentScopeID: scopeID
                ) else {
                    continue
                }

                projects = fetchedProjects.sorted {
                    $0.name.localizedStandardCompare($1.name) == .orderedAscending
                }
                recentDeployments = fetchedDeployments
            } catch {
                guard RefreshCoordinator.shouldApply(
                    requestGeneration: generation,
                    currentGeneration: refreshGeneration,
                    scopeAtStart: scopeAtStart,
                    currentScopeID: scopeID
                ) else {
                    continue
                }
                if handleUnauthorizedIfNeeded(error) { return }
                errorMessage = NetworkUserMessage.text(for: error)
            }

            if generation == refreshGeneration {
                isRefreshing = false
                break
            }
        }
    }

    func selectScope(_ newScope: String) async {
        guard newScope != scopeID else { return }
        refreshGeneration &+= 1
        scopeID = newScope
        UserDefaults.standard.set(newScope, forKey: Self.scopeKey)
        projects = []
        recentDeployments = []
        errorMessage = nil
        await refresh()
    }

    func redeploy(_ deployment: VercelDeployment) async throws -> VercelRedeployResult {
        guard let api else {
            throw VercelAPIError.invalidResponse
        }
        let scopeAtStart = scopeID
        do {
            let result = try await api.redeploy(deployment: deployment, teamID: activeTeamID)
            if scopeAtStart == scopeID {
                await refresh()
            }
            return result
        } catch {
            _ = handleUnauthorizedIfNeeded(error)
            throw error
        }
    }

    func deploymentEvents(for deployment: VercelDeployment) async throws -> [VercelDeploymentEvent] {
        guard let api else { return [] }
        let scopeAtStart = scopeID
        do {
            let events = try await api.deploymentEvents(
                deploymentID: deployment.uid,
                teamID: activeTeamID
            )
            guard scopeAtStart == scopeID else { return [] }
            return events
        } catch {
            if handleUnauthorizedIfNeeded(error) { return [] }
            throw error
        }
    }

    func deployments(for project: VercelProject) async throws -> [VercelDeployment] {
        guard let api else { return [] }
        let scopeAtStart = scopeID
        let teamIDAtStart = activeTeamID
        do {
            let result = try await api.deployments(
                teamID: teamIDAtStart,
                projectID: project.id,
                limit: 50
            )
            guard scopeAtStart == scopeID else { return [] }
            return result
        } catch {
            if handleUnauthorizedIfNeeded(error) { return [] }
            throw error
        }
    }

    func signOut(sessionMessage: String? = nil) {
        refreshGeneration &+= 1
        KeychainStore.delete()
        api = nil
        user = nil
        teams = []
        projects = []
        recentDeployments = []
        scopeID = ""
        UserDefaults.standard.removeObject(forKey: Self.scopeKey)
        errorMessage = sessionMessage
        isAuthenticated = false
        hasBootstrapped = false
    }

    @discardableResult
    private func handleUnauthorizedIfNeeded(_ error: Error) -> Bool {
        guard VercelAPIError.isUnauthorized(error) else { return false }
        signOut(sessionMessage: NetworkUserMessage.text(for: error))
        return true
    }

    /// Drops a persisted team scope that no longer exists for the signed-in user.
    private func reconcileScopeWithTeams() {
        guard !scopeID.isEmpty else { return }
        if !teams.contains(where: { $0.id == scopeID }) {
            scopeID = ""
            UserDefaults.standard.set("", forKey: Self.scopeKey)
        }
    }
}
