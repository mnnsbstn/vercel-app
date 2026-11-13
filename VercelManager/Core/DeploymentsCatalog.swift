import Foundation

struct DeploymentsFetchResult: Equatable {
    let deployments: [VercelDeployment]
    let loadedPages: Int
    let hasMorePages: Bool

    var loadedCount: Int { deployments.count }
}

enum DeploymentsPagination {
    static let pageSize = 100
    static let maxPagesAccount = 3
    static let maxPagesProject = 8

    static var maxAccountDeployments: Int { maxPagesAccount * pageSize }
    static var maxProjectDeployments: Int { maxPagesProject * pageSize }

    static func shouldFetchAnotherPage(pageIndex: Int, maxPages: Int, hasNextCursor: Bool) -> Bool {
        guard hasNextCursor else { return false }
        return pageIndex + 1 < maxPages
    }

    static func isTruncatedAfterPage(pageIndex: Int, maxPages: Int, hasNextCursor: Bool) -> Bool {
        hasNextCursor && pageIndex + 1 >= maxPages
    }
}

enum DeploymentEnvironmentLabel {
    static func label(for target: String?) -> String {
        switch target?.lowercased() {
        case "production":
            return "Production"
        case "staging":
            return "Staging"
        case nil, "":
            return "Preview"
        default:
            return "Preview"
        }
    }
}

extension Array where Element == VercelDeployment {
    func sortedByNewest() -> [VercelDeployment] {
        sorted { ($0.created ?? 0) > ($1.created ?? 0) }
    }
}
