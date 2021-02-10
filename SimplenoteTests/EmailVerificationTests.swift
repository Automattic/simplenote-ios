import XCTest
@testable import Simplenote


// MARK: - EmailVerificationTests
//
class EmailVerificationTests: XCTestCase {

    func testEmailVerificationCorrectlyParsesToken() {
        let payload = [
            "token": #"{"username": "1234"}"#
        ]
        let parsed = EmailVerification(payload: payload)
        XCTAssertEqual(parsed.token?.username, "1234")
    }

    func testEmailVerificationCorrectlyParsesPending() {
        let payload = [
            "sent_to": "1234"
        ]
        let parsed = EmailVerification(payload: payload)
        XCTAssertEqual(parsed.sentTo, "1234")
    }

    func testEmailVerificationCorrectlyParsesEmptyPayload() {
        let payload: [AnyHashable: Any] = [:]
        let parsed = EmailVerification(payload: payload)
        XCTAssertNil(parsed.token)
        XCTAssertNil(parsed.sentTo)
    }

    func testEmailVerificationIgnoresBrokenPayload() {
        let payload: [AnyHashable: Any] = [
            "token": #"{"user": "1234"}"#,
            "sent_to": 1234
        ]
        let parsed = EmailVerification(payload: payload)
        XCTAssertNil(parsed.token)
        XCTAssertNil(parsed.sentTo)
    }
}
