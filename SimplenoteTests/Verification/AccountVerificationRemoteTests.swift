import XCTest
@testable import Simplenote

// MARK: - AccountVerificationRemoteTests
//
class AccountVerificationRemoteTests: XCTestCase {
    private lazy var urlSession = MockURLSession()
    private lazy var remote = AccountRemote(urlSession: urlSession)

    func testSuccessWhenStatusCodeIs2xx() {
        for _ in 0..<5 {
            test(withStatusCode: Int.random(in: 200..<300), expectedResult: .success(nil))
        }
    }

    func testFailureWhenStatusCodeIs4xxOr5xx() {
        for _ in 0..<5 {
            let statusCode = Int.random(in: 400..<600)
            test(withStatusCode: statusCode, expectedResult: .failure(RemoteError(statusCode: statusCode)))
        }
    }

    func testFailureWhenNoResponse() {
        test(withStatusCode: nil, expectedResult: .failure(RemoteError(statusCode: 0)))
    }

    private func test(withStatusCode statusCode: Int?, expectedResult: Result<Data?, RemoteError>) {
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
