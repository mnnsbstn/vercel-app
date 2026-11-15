import XCTest
@testable import VercelManager

// MARK: - URLProtocol mock

final class MockVercelURLProtocol: URLProtocol {
    nonisolated(unsafe) static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        request.url?.host == "api.vercel.com"
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

enum VercelAPITestSupport {
    static func makeSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockVercelURLProtocol.self]
        return URLSession(configuration: config)
    }

    static func jsonResponse(
        for request: URLRequest,
        statusCode: Int,
        body: String
    ) throws -> (HTTPURLResponse, Data) {
        guard let url = request.url else {
            throw URLError(.badURL)
        }
        let response = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!
        return (response, Data(body.utf8))
    }

    static func queryValue(_ name: String, in request: URLRequest) -> String? {
        guard let url = request.url,
              let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems else {
            return nil
        }
        return items.first(where: { $0.name == name })?.value
    }

  /// URLSession often supplies POST data via `httpBodyStream`, not `httpBody`.
    static func httpBodyData(from request: URLRequest) -> Data? {
        if let body = request.httpBody, !body.isEmpty { return body }
        guard let stream = request.httpBodyStream else { return nil }
        stream.open()
        defer { stream.close() }
        var data = Data()
        let bufferSize = 4096
        var buffer = [UInt8](repeating: 0, count: bufferSize)
        while stream.hasBytesAvailable {
            let read = stream.read(&buffer, maxLength: bufferSize)
            if read <= 0 { break }
            data.append(buffer, count: read)
        }
        return data.isEmpty ? nil : data
    }
}

// MARK: - Integration tests

final class VercelAPIMockTests: XCTestCase {
    override func tearDown() {
        MockVercelURLProtocol.handler = nil
        super.tearDown()
    }

    func testUserUnauthorizedMapsToAPIError() async {
        MockVercelURLProtocol.handler = { request in
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertTrue(request.value(forHTTPHeaderField: "Authorization")?.hasPrefix("Bearer ") == true)
            return try VercelAPITestSupport.jsonResponse(
                for: request,
                statusCode: 401,
                body: #"{"error":{"message":"Unauthorized"}}"#
            )
        }

        let api = VercelAPI(token: "test-token", session: VercelAPITestSupport.makeSession())

        do {
            _ = try await api.user()
            XCTFail("Expected unauthorized error")
        } catch let error as VercelAPIError {
            XCTAssertTrue(VercelAPIError.isUnauthorized(error))
            XCTAssertEqual(error.httpStatusCode, 401)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testProjectsPaginationFollowsCursor() async throws {
        MockVercelURLProtocol.handler = { request in
            XCTAssertTrue(request.url?.path.hasSuffix("/v9/projects") == true)
            XCTAssertEqual(VercelAPITestSupport.queryValue("teamId", in: request), "team_test")
            let cursor = VercelAPITestSupport.queryValue("from", in: request)
            if cursor == nil {
                return try VercelAPITestSupport.jsonResponse(
                    for: request,
                    statusCode: 200,
                    body: """
                    {
                      "projects": [{"id": "p1", "name": "Alpha"}],
                      "pagination": {"next": "page_2"}
                    }
                    """
                )
            }
            XCTAssertEqual(cursor, "page_2")
            return try VercelAPITestSupport.jsonResponse(
                for: request,
                statusCode: 200,
                body: """
                {
                  "projects": [{"id": "p2", "name": "Beta"}],
                  "pagination": {}
                }
                """
            )
        }

        let api = VercelAPI(token: "test-token", session: VercelAPITestSupport.makeSession())
        let result = try await api.projects(teamID: "team_test")

        XCTAssertEqual(result.loadedPages, 2)
        XCTAssertFalse(result.hasMorePages)
        XCTAssertEqual(result.projects.map(\.name), ["Alpha", "Beta"])
    }

    func testDeploymentEventsDecodesViaHTTP() async throws {
        MockVercelURLProtocol.handler = { request in
            XCTAssertTrue(request.url?.path.contains("/v3/deployments/dpl_mock/events") == true)
            return try VercelAPITestSupport.jsonResponse(
                for: request,
                statusCode: 200,
                body: """
                [
                  {"type": "stdout", "text": "step one"},
                  {"type": "stderr", "payload": {"text": "step two", "type": "stderr"}}
                ]
                """
            )
        }

        let api = VercelAPI(token: "test-token", session: VercelAPITestSupport.makeSession())
        let events = try await api.deploymentEvents(deploymentID: "dpl_mock", teamID: nil, limit: 200)

        XCTAssertEqual(events.count, 2)
        XCTAssertEqual(events[0].message, "step one")
        XCTAssertEqual(events[1].message, "step two")
    }

    func testRedeployPOSTIncludesTeamQueryAndBody() async throws {
        MockVercelURLProtocol.handler = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(VercelAPITestSupport.queryValue("teamId", in: request), "team_x")
            let payload = try XCTUnwrap(VercelAPITestSupport.httpBodyData(from: request))
            let redeployBody = try JSONDecoder().decode(RedeployRequestBuilder.Body.self, from: payload)
            XCTAssertEqual(redeployBody.deploymentId, "dpl_source")
            XCTAssertEqual(redeployBody.name, "demo-app")
            return try VercelAPITestSupport.jsonResponse(
                for: request,
                statusCode: 200,
                body: """
                {"id": "dpl_new", "url": "demo.vercel.app", "readyState": "QUEUED", "name": "demo-app"}
                """
            )
        }

        let deployment = VercelDeployment(
            uid: "dpl_source",
            name: "demo-app",
            url: nil,
            state: nil,
            readyState: "READY",
            target: nil,
            created: nil,
            meta: nil,
            projectId: "prj_1"
        )

        let api = VercelAPI(token: "test-token", session: VercelAPITestSupport.makeSession())
        let result = try await api.redeploy(deployment: deployment, teamID: "team_x")

        XCTAssertEqual(result.id, "dpl_new")
        XCTAssertEqual(result.readyState, "QUEUED")
    }
}