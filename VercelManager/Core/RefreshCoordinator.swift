import Foundation

/// Guards against stale async API results after account/scope changes or superseded refreshes.
enum RefreshCoordinator {
    static func shouldApply(
        requestGeneration: UInt,
        currentGeneration: UInt,
        scopeAtStart: String,
        currentScopeID: String
    ) -> Bool {
        requestGeneration == currentGeneration && scopeAtStart == currentScopeID
    }
}
