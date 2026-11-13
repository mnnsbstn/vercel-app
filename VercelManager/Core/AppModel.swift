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
        guard let api, !isRefreshing else { return }
        isRefreshing = true
        errorMessage = nil
        defer { isRefreshing = false }

        do {
            async let loadedProjects = api.projects(teamID: activeTeamID)
            async let loadedDeployments = api.deployments(teamID: activeTeamID)

            let fetchedProjects = try await loadedProjects
            let fetchedDeployments = try await loadedDeployments
            projects = fetchedProjects.sorted {
                $0.name.localizedStandardCompare($1.name) == .orderedAscending
            }
            recentDeployments = fetchedDeployments
        } catch {
            if handleUnauthorizedIfNeeded(error) { return }
            errorMessage = NetworkUserMessage.text(for: error)
        }
    }

    func selectScope(_ newScope: String) async {
        guard newScope != scopeID else { return }
        scopeID = newScope
        UserDefaults.standard.set(newScope, forKey: Self.scopeKey)
        projects = []
        recentDeployments = []
        await refresh()
    }

    func deployments(for project: VercelProject) async throws -> [VercelDeployment] {
        guard let api else { return [] }
        do {
            return try await api.deployments(
                teamID: activeTeamID,
                projectID: project.id,
                limit: 50
            )
        } catch {
            if handleUnauthorizedIfNeeded(error) { return [] }
            throw error
        }
    }

    func signOut(sessionMessage: String? = nil) {
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
