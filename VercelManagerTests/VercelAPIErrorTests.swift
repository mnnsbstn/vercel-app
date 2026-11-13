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
