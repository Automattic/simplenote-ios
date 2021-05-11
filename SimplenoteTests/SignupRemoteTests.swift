import XCTest
@testable import Simplenote

class SignupRemoteTests: XCTestCase {
    private lazy var urlSession = MockURLSession()
    private lazy var signupRemote = SignupRemote(urlSession: urlSession)

    func testSuccessWhenStatusCodeIs2xx() {
        for _ in 0..<5 {
            test(withStatusCode: Int.random(in: 200..<300), email: "email@gmail.com", expectedResult: SignupRemote.Result.success)
        }
    }

    func testFailureWhenStatusCodeIs4xxOr5xx() {
        for _ in 0..<5 {
            let statusCode = Int.random(in: 400..<600)
            test(withStatusCode: statusCode, email: "email@gmail.com", expectedResult: SignupRemote.Result.failure(statusCode, nil))
        }
    }

    func testRequestSetsEmailToCorrectCase() throws {
        signupRemote.signup(with: "EMAIL@gmail.com", completion: { _ in })

        let expecation = "email@gmail.com"
        let body: Dictionary<String, String> = try XCTUnwrap(urlSession.lastRequest?.decodeHtmlBody())
        let decodedEmail = try XCTUnwrap(body["username"])

        XCTAssertEqual(expecation, decodedEmail)
    }

    func testRequestSetsEmailToCorrectCaseWithSpecialCharacters() throws {
        signupRemote.signup(with: "EMAIL123456@#$%^@gmail.com", completion: { _ in })

        let expecation = "email123456@#$%^@gmail.com"
        let body: Dictionary<String, String> = try XCTUnwrap(urlSession.lastRequest?.decodeHtmlBody())
        let decodedEmail = try XCTUnwrap(body["username"])

        XCTAssertEqual(expecation, decodedEmail)
    }

    func testRequestSetsEmailToCorrectCaseWithMixedCase() throws {
        signupRemote.signup(with: "eMaIl@gmail.com", completion: { _ in })

        let expecation = "email@gmail.com"
        let body: Dictionary<String, String> = try XCTUnwrap(urlSession.lastRequest?.decodeHtmlBody())
        let decodedEmail = try XCTUnwrap(body["username"])

        XCTAssertEqual(expecation, decodedEmail)
    }

    private func test(withStatusCode statusCode: Int?, email: String, expectedResult: SignupRemote.Result) {
        urlSession.data = (nil,
                           response(with: statusCode),
                           nil)

        let expectation = self.expectation(description: "Verify is called")

        signupRemote.signup(with: email) { (result) in
            XCTAssertEqual(result, expectedResult)
            expectation.fulfill()
        }

        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
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
