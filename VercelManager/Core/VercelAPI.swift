import Foundation

enum VercelAPIError: LocalizedError {
    case invalidResponse
    case invalidURL
    case unexpectedStatus(Int, String)

    var httpStatusCode: Int? {
        if case let .unexpectedStatus(code, _) = self { return code }
        return nil
    }

    static func isUnauthorized(_ error: Error) -> Bool {
        guard let apiError = error as? VercelAPIError else { return false }
        return apiError.httpStatusCode == 401
    }

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Die Vercel-Antwort konnte nicht gelesen werden."
        case .invalidURL:
            return "Die Anfrage-URL ist ungültig."
        case let .unexpectedStatus(status, message):
            if status == 401 {
                return "Token ungültig oder abgelaufen. Bitte einen gültigen Vercel-Token verwenden."
            }
            if status == 403 {
                return "Keine Berechtigung für diesen Vercel-Account oder dieses Team."
            }
            if status == 429 {
                return "Vercel begrenzt aktuell die Anfragen. Bitte später erneut versuchen."
            }
            return "Vercel API (\(status)): \(message)"
        }
    }
}

struct VercelAPI {
    private let token: String
    private let baseURL = "https://api.vercel.com"

    init(token: String) {
        self.token = token
    }

    func user() async throws -> VercelUser {
        let response: UserResponse = try await get("/v2/user")
        return response.user
    }

    func teams() async throws -> [VercelTeam] {
        let response: TeamsResponse = try await get("/v2/teams")
        return response.teams
    }

    func projects(teamID: String?) async throws -> [VercelProject] {
        var all: [VercelProject] = []
        var cursor: String?
        var usedCursors = Set<String>()

        // Avoid an unbounded request loop if the remote pagination is malformed.
        for _ in 0..<10 {
            var query = [URLQueryItem(name: "limit", value: "100")]
            if let cursor {
                query.append(URLQueryItem(name: "from", value: cursor))
            }

            let response: ProjectsResponse = try await get(
                "/v9/projects", teamID: teamID, query: query
            )
            all.append(contentsOf: response.projects)

            guard let next = response.pagination?.next?.value,
                  !next.isEmpty, !usedCursors.contains(next) else {
                break
            }
            usedCursors.insert(next)
            cursor = next
        }
        return all
    }

    func deployments(
        teamID: String?,
        projectID: String? = nil,
        limit: Int = 40
    ) async throws -> [VercelDeployment] {
        var query = [URLQueryItem(name: "limit", value: String(min(max(limit, 1), 100)))]
        if let projectID {
            query.append(URLQueryItem(name: "projectId", value: projectID))
        }
        let response: DeploymentsResponse = try await get(
            "/v6/deployments", teamID: teamID, query: query
        )
        return response.deployments
    }

    /// Build output via official `GET /v3/deployments/{idOrUrl}/events` (JSON, not live stream).
    func deploymentEvents(
        deploymentID: String,
        teamID: String?,
        limit: Int = 200
    ) async throws -> [VercelDeploymentEvent] {
        let capped = min(max(limit, 1), 500)
        let query = [
            URLQueryItem(name: "direction", value: "backward"),
            URLQueryItem(name: "limit", value: String(capped)),
            URLQueryItem(name: "delimiter", value: "0"),
        ]
        let path = "/v3/deployments/\(deploymentID)/events"
        let data = try await getData(path, teamID: teamID, query: query, timeout: 45)
        return try VercelDeploymentEvent.decodeList(from: data)
    }

    /// Redeploy via `POST /v13/deployments` with `deploymentId` (settings inherited from source).
    func redeploy(deployment: VercelDeployment, teamID: String?) async throws -> VercelRedeployResult {
        let body = try RedeployRequestBuilder.body(for: deployment)
        return try await post("/v13/deployments", teamID: teamID, body: body)
    }

    private func post<Body: Encodable, T: Decodable>(
        _ path: String,
        teamID: String? = nil,
        body: Body,
        timeout: TimeInterval = 60
    ) async throws -> T {
        guard var components = URLComponents(string: baseURL + path) else {
            throw VercelAPIError.invalidURL
        }
        var items: [URLQueryItem] = []
        if let teamID, !teamID.isEmpty {
            items.append(URLQueryItem(name: "teamId", value: teamID))
        }
        components.queryItems = items.isEmpty ? nil : items

        guard let url = components.url else { throw VercelAPIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = timeout
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        request.cachePolicy = .reloadIgnoringLocalCacheData

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw VercelAPIError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            let payload = try? JSONDecoder().decode(APIErrorBody.self, from: data)
            let message = payload?.error.message ?? HTTPURLResponse.localizedString(
                forStatusCode: httpResponse.statusCode
            )
            throw VercelAPIError.unexpectedStatus(httpResponse.statusCode, message)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }

    private func getData(
        _ path: String,
        teamID: String? = nil,
        query: [URLQueryItem] = [],
        timeout: TimeInterval = 25
    ) async throws -> Data {
        guard var components = URLComponents(string: baseURL + path) else {
            throw VercelAPIError.invalidURL
        }
        var items = query
        if let teamID, !teamID.isEmpty {
            items.append(URLQueryItem(name: "teamId", value: teamID))
        }
        components.queryItems = items.isEmpty ? nil : items

        guard let url = components.url else { throw VercelAPIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = timeout
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.cachePolicy = .reloadIgnoringLocalCacheData

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw VercelAPIError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            let payload = try? JSONDecoder().decode(APIErrorBody.self, from: data)
            let message = payload?.error.message ?? HTTPURLResponse.localizedString(
                forStatusCode: httpResponse.statusCode
            )
            throw VercelAPIError.unexpectedStatus(httpResponse.statusCode, message)
        }
        return data
    }

    private func get<T: Decodable>(
        _ path: String,
        teamID: String? = nil,
        query: [URLQueryItem] = []
    ) async throws -> T {
        let data = try await getData(path, teamID: teamID, query: query, timeout: 25)
        return try JSONDecoder().decode(T.self, from: data)
    }
}

enum NetworkUserMessage {
    static func text(for error: Error) -> String {
        if let apiError = error as? VercelAPIError {
            return apiError.localizedDescription
        }
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return "Keine Internetverbindung. Bitte Netzwerk prüfen und erneut versuchen."
            case .timedOut:
                return "Die Anfrage hat zu lange gedauert. Bitte später erneut versuchen."
            default:
                return "Netzwerkfehler. Bitte Verbindung prüfen und erneut versuchen."
            }
        }
        return error.localizedDescription
    }
}

private struct APIErrorBody: Decodable {
    struct Message: Decodable {
        let message: String?
    }

    let error: Message
}
