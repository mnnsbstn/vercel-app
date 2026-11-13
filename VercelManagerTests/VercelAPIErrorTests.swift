import XCTest
@testable import VercelManager

final class VercelAPIErrorTests: XCTestCase {
    func testUnauthorizedDetection() {
        let error = VercelAPIError.unexpectedStatus(401, "Unauthorized")
        XCTAssertTrue(VercelAPIError.isUnauthorized(error))
        XCTAssertEqual(error.httpStatusCode, 401)
    }

    func testNonUnauthorizedErrors() {
        let forbidden = VercelAPIError.unexpectedStatus(403, "Forbidden")
        XCTAssertFalse(VercelAPIError.isUnauthorized(forbidden))

        let urlError = URLError(.notConnectedToInternet)
        XCTAssertFalse(VercelAPIError.isUnauthorized(urlError))
    }
}

final class RefreshCoordinatorTests: XCTestCase {
    func testAppliesWhenGenerationAndScopeMatch() {
        XCTAssertTrue(
            RefreshCoordinator.shouldApply(
                requestGeneration: 2,
                currentGeneration: 2,
                scopeAtStart: "team_a",
                currentScopeID: "team_a"
            )
        )
    }

    func testRejectsSupersededGeneration() {
        XCTAssertFalse(
            RefreshCoordinator.shouldApply(
                requestGeneration: 1,
                currentGeneration: 2,
                scopeAtStart: "team_a",
                currentScopeID: "team_a"
            )
        )
    }

    func testRejectsScopeChangeDuringRequest() {
        XCTAssertFalse(
            RefreshCoordinator.shouldApply(
                requestGeneration: 2,
                currentGeneration: 2,
                scopeAtStart: "team_a",
                currentScopeID: ""
            )
        )
    }
}

final class DeploymentEventDecodingTests: XCTestCase {
    func testDecodesNestedPayloadEvents() throws {
        let json = """
        [
          {
            "type": "stdout",
            "created": 1700000000000,
            "payload": {
              "text": "Build completed",
              "type": "stdout"
            }
          },
          {
            "type": "stderr",
            "text": "warning: optional step"
          }
        ]
        """.data(using: .utf8)!

        let events = try VercelDeploymentEvent.decodeList(from: json)
        XCTAssertEqual(events.count, 2)
        XCTAssertTrue(events.contains { $0.message == "Build completed" })
        XCTAssertTrue(events.contains { $0.message == "warning: optional step" })
    }
}

final class NetworkUserMessageTests: XCTestCase {
    func testOfflineMessage() {
        let message = NetworkUserMessage.text(for: URLError(.notConnectedToInternet))
        XCTAssertTrue(message.contains("Internetverbindung"))
    }

    func testTimeoutMessage() {
        let message = NetworkUserMessage.text(for: URLError(.timedOut))
        XCTAssertTrue(message.contains("lange"))
    }

    func testAPIErrorPassthrough() {
        let error = VercelAPIError.unexpectedStatus(429, "rate limited")
        let message = NetworkUserMessage.text(for: error)
        XCTAssertTrue(message.contains("Anfragen"))
    }
}
