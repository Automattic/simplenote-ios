import XCTest
@testable import Simplenote

// MARK: - AccountVerificationRemoteTests
//
class AccountVerificationRemoteTests: XCTestCase {
    private lazy var urlSession = MockURLSession()
    private lazy var remote = AccountVerificationRemote(urlSession: urlSession)

    func testSuccessWhenStatusCodeIs2xx() {
        for _ in 0..<5 {
            test(withStatusCode: Int.random(in: 200..<300), expectedResult: true)
        }
    }

    func testFailureWhenStatusCodeIs4xxOr5xx() {
        for _ in 0..<5 {
            test(withStatusCode: Int.random(in: 400..<600), expectedResult: false)
        }
    }

    func testFailureWhenNoResponse() {
        test(withStatusCode: nil, expectedResult: false)
    }

    private func test(withStatusCode statusCode: Int?, expectedResult: Bool) {
        urlSession.data = (nil,
                           response(with: statusCode),
                           nil)

        let expectation = self.expectation(description: "Verify is called")

        remote.verify(email: UUID().uuidString) { (result) in
            XCTAssertEqual(result, expectedResult)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
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
