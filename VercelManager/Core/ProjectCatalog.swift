import Foundation

struct ProjectsFetchResult: Equatable {
    let projects: [VercelProject]
    let loadedPages: Int
    let hasMorePages: Bool

    var loadedCount: Int { projects.count }
}

enum ProjectsPagination {
    static let maxPages = 10
    static let pageSize = 100

    static var maxLoadedProjects: Int { maxPages * pageSize }

    static func shouldFetchAnotherPage(pageIndex: Int, hasNextCursor: Bool) -> Bool {
        guard hasNextCursor else { return false }
        return pageIndex + 1 < maxPages
    }

    static func isTruncatedAfterPage(pageIndex: Int, hasNextCursor: Bool) -> Bool {
        hasNextCursor && pageIndex + 1 >= maxPages
    }
}

enum ProjectSearchFilter {
    static func matching(_ projects: [VercelProject], query: String) -> [VercelProject] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return projects }
        return projects.filter {
            $0.name.localizedCaseInsensitiveContains(trimmed)
                || ($0.framework?.localizedCaseInsensitiveContains(trimmed) ?? false)
        }
    }
}
