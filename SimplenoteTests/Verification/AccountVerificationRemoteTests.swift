import XCTest
@testable import Simplenote

// MARK: - AccountVerificationRemoteTests
//
class AccountVerificationRemoteTests: XCTestCase {
    private lazy var urlSession = MockURLSession()
    private lazy var remote = AccountVerificationRemote(urlSession: urlSession)

    func testSuccessWhenStatusCodeIs2xx() {
        for _ in 0..<5 {
            test(withStatusCode: Int.random(in: 200..<300), expectedResult: Remote.Result.success)
        }
    }

    func testFailureWhenStatusCodeIs4xxOr5xx() {
        for _ in 0..<5 {
            let statusCode = Int.random(in: 400..<600)
            test(withStatusCode: statusCode, expectedResult: Remote.Result.failure(statusCode, nil))
        }
    }

    func testFailureWhenNoResponse() {
        test(withStatusCode: nil, expectedResult: Remote.Result.failure(0, nil))
    }

    private func test(withStatusCode statusCode: Int?, expectedResult: Remote.Result) {
        urlSession.data = (nil,
                           response(with: statusCode),
                           nil)

        let expectation = self.expectation(description: "Verify is called")

        remote.verify(email: UUID().uuidString) { (result) in
            XCTAssertEqual(result, expectedResult)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 3, handler: nil)
    }

    private func response(with statusCode: Int?) -> HTTPURLResponse? {
        guard let statusCode = statusCode else {
            return nil
        }
        return HTTPURLResponse(url: URL(fileURLWithPath: "/"),
                               statusCode: statusCode,
                               httpVersion: nil,
                               headerFields: nil)
    }
}
