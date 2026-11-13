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

struct VercelDeploymentMeta: Decodable, Hashable {
    let githubCommitMessage: String?
    let githubCommitSha: String?
    let githubCommitRef: String?
}

struct VercelDeployment: Decodable, Identifiable, Hashable {
    let uid: String
    let name: String?
    let url: String?
    let state: String?
    let readyState: String?
    let target: String?
    let created: Double?
    let meta: VercelDeploymentMeta?
    let projectId: String?

    var id: String { uid }

    var isProductionTarget: Bool {
        target?.lowercased() == "production"
    }

    var branchLabel: String? {
        guard let ref = meta?.githubCommitRef, !ref.isEmpty else { return nil }
        return ref
    }

    var versionSummary: String? {
        if let sha = meta?.githubCommitSha {
            let short = String(sha.prefix(7))
            if let message = meta?.githubCommitMessage, !message.isEmpty {
                return "\(short) · \(message)"
            }
            return short
        }
        return meta?.githubCommitMessage
    }

    var currentState: String {
        (readyState ?? state ?? "UNKNOWN").uppercased()
    }

    var environmentLabel: String {
        DeploymentEnvironmentLabel.label(for: target)
    }

    private enum CodingKeys: String, CodingKey {
        case uid, name, url, state, readyState, target, created, createdAt, meta, projectId
    }

    init(
        uid: String,
        name: String? = nil,
        url: String? = nil,
        state: String? = nil,
        readyState: String? = nil,
        target: String? = nil,
        created: Double? = nil,
        meta: VercelDeploymentMeta? = nil,
        projectId: String? = nil
    ) {
        self.uid = uid
        self.name = name
        self.url = url
        self.state = state
        self.readyState = readyState
        self.target = target
        self.created = created
        self.meta = meta
        self.projectId = projectId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uid = try container.decode(String.self, forKey: .uid)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        url = try container.decodeIfPresent(String.self, forKey: .url)
        state = try container.decodeIfPresent(String.self, forKey: .state)
        readyState = try container.decodeIfPresent(String.self, forKey: .readyState)
        target = try container.decodeIfPresent(String.self, forKey: .target)
        meta = try container.decodeIfPresent(VercelDeploymentMeta.self, forKey: .meta)
        projectId = try container.decodeIfPresent(String.self, forKey: .projectId)
        if let timestamp = try container.decodeIfPresent(Double.self, forKey: .created) {
            created = timestamp
        } else {
            created = try container.decodeIfPresent(Double.self, forKey: .createdAt)
        }
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
    let pagination: Pagination?
}

struct VercelRedeployResult: Decodable {
    let id: String
    let url: String?
    let readyState: String?
    let name: String?
}

enum RedeployValidationError: LocalizedError {
    case missingProjectName

    var errorDescription: String? {
        switch self {
        case .missingProjectName:
            return "Für ein Redeploy fehlt der Projektname in den Deployment-Daten."
        }
    }
}

enum RedeployRequestBuilder {
    struct Body: Encodable, Equatable {
        let name: String
        let deploymentId: String
    }

    static func body(for deployment: VercelDeployment) throws -> Body {
        guard let projectName = deployment.name?.trimmingCharacters(in: .whitespacesAndNewlines),
              !projectName.isEmpty else {
            throw RedeployValidationError.missingProjectName
        }
        return Body(name: projectName, deploymentId: deployment.uid)
    }
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
