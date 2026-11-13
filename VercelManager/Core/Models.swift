import Foundation

struct VercelUser: Decodable {
    let id: String?
    let username: String?
    let email: String?
    let name: String?
}

struct UserResponse: Decodable {
    let user: VercelUser
}

struct VercelTeam: Decodable, Identifiable, Hashable {
    let id: String
    let name: String
    let slug: String?
}

struct TeamsResponse: Decodable {
    let teams: [VercelTeam]
}

struct VercelProject: Decodable, Identifiable, Hashable {
    let id: String
    let name: String
    let framework: String?
    let updatedAt: Double?
}

struct VercelDeployment: Decodable, Identifiable, Hashable {
    let uid: String
    let name: String?
    let url: String?
    let state: String?
    let readyState: String?
    let target: String?
    let created: Double?

    var id: String { uid }

    var currentState: String {
        (readyState ?? state ?? "UNKNOWN").uppercased()
    }

    var environmentLabel: String {
        target == "production" ? "Production" : "Preview"
    }

    var deploymentURL: URL? {
        guard let url, !url.isEmpty else { return nil }
        let raw = url.hasPrefix("https://") ? url : "https://" + url
        guard let parsed = URL(string: raw), parsed.scheme == "https",
              parsed.host != nil else { return nil }
        return parsed
    }
}

struct Pagination: Decodable {
    let next: PageCursor?
}

struct PageCursor: Decodable {
    let value: String

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            value = string
        } else if let integer = try? container.decode(Int64.self) {
            value = String(integer)
        } else {
            throw DecodingError.typeMismatch(
                String.self,
                .init(codingPath: decoder.codingPath, debugDescription: "Ungültiger Pagination-Cursor")
            )
        }
    }
}

struct ProjectsResponse: Decodable {
    let projects: [VercelProject]
    let pagination: Pagination?
}

struct DeploymentsResponse: Decodable {
    let deployments: [VercelDeployment]
}

extension Double {
    var vercelDate: Date { Date(timeIntervalSince1970: self / 1000) }
}
