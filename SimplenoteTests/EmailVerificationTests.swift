import XCTest
@testable import Simplenote


// MARK: - EmailVerificationTests
//
class EmailVerificationTests: XCTestCase {

    func testEmailVerificationCorrectlyParsesSentStatusWithEmail() {
        let rawSent = [ "status": "SENT:1234" ]
        let parsedSent = EmailVerification(payload: rawSent)
        XCTAssertEqual(parsedSent?.status, .sent(email: "1234"))
    }

    func testEmailVerificationCorrectlyParsesSentStatusWithoutEmail() {
        let rawSent = [ "status": "SENT" ]
        let parsedSent = EmailVerification(payload: rawSent)
        XCTAssertEqual(parsedSent?.status, .sent(email: nil))
    }

    func testEmailVerificationCorrectlyParsesVerifiedStatus() {
        let rawVerified = [ "status": "verified" ]
        let parsedVerified = EmailVerification(payload: rawVerified)
        XCTAssertEqual(parsedVerified?.status, .verified)
    }

    func testEmailVerificationCorrectlyParsesVerifiedStatusAndDisregardsAnyExtraColonSeparatedValues() {
        let rawVerified = [ "status": "verified:1234" ]
        let parsedVerified = EmailVerification(payload: rawVerified)
        XCTAssertEqual(parsedVerified?.status, .verified)
    }

    func testEmailVerificationCorrectlyParsesTokenFields() {
        let rawVerified = [ "status": "verified:1234", "token": "yosemite" ]
        let parsedVerified = EmailVerification(payload: rawVerified)
        XCTAssertEqual(parsedVerified?.token, "yosemite")
    }
}


// MARK: - EmailVerificationStatus Helpers
//
private extension EmailVerificationStatus {

    init?(payload: [String: String]) {
        let data = try! JSONEncoder().encode(payload)
        let string = String(data: data, encoding: .utf8)!

        self.init(rawValue: string)
    }
}
