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

struct FlexibleVercelTimestamp: Decodable {
    let date: Date?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let milliseconds = try? container.decode(Double.self) {
            date = Date(timeIntervalSince1970: milliseconds / 1000)
        } else if let string = try? container.decode(String.self), let milliseconds = Double(string) {
            date = Date(timeIntervalSince1970: milliseconds / 1000)
        } else {
            date = nil
        }
    }
}

private struct DeploymentEventPayload: Decodable {
    let text: String?
    let type: String?
    let id: String?
    let created: FlexibleVercelTimestamp?
}

private struct DeploymentEventDTO: Decodable {
    let type: String?
    let created: FlexibleVercelTimestamp?
    let text: String?
    let payload: DeploymentEventPayload?
    let id: String?

    func normalized(index: Int) -> VercelDeploymentEvent? {
        let raw = text ?? payload?.text
        guard let raw else { return nil }
        let message = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { return nil }
        let eventType = (type ?? payload?.type ?? "log").lowercased()
        let eventID = id ?? payload?.id ?? "evt-\(index)"
        return VercelDeploymentEvent(
            id: eventID,
            type: eventType,
            message: message,
            createdAt: created?.date ?? payload?.created?.date
        )
    }
}

struct VercelDeploymentEvent: Identifiable, Hashable {
    let id: String
    let type: String
    let message: String
    let createdAt: Date?

    var typeLabel: String {
        switch type {
        case "stderr", "error": return "Fehler"
        case "stdout", "command", "stdout-end": return "Build"
        case "deployment-state": return "Status"
        default: return type.capitalized
        }
    }
}

extension VercelDeploymentEvent {
    static func decodeList(from data: Data) throws -> [VercelDeploymentEvent] {
        let decoder = JSONDecoder()
        let dtos = try decoder.decode([DeploymentEventDTO].self, from: data)
        return dtos.enumerated().compactMap { $1.normalized(index: $0) }
    }
}

extension Double {
    var vercelDate: Date { Date(timeIntervalSince1970: self / 1000) }
}
