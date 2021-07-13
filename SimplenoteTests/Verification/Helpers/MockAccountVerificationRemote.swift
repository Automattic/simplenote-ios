import XCTest
@testable import Simplenote

class MockAccountVerificationRemote: AccountVerificationRemote {
    private var pendingVerifications: [(email: String, completion: (Remote.Result) -> Void)] = []

    override func verify(email: String, completion: @escaping (Remote.Result) -> Void) {
        pendingVerifications.append((email, completion))
    }

    func processVerification(for email: String, with result: Remote.Result) {
        guard let index = pendingVerifications.firstIndex(where: { $0.email == email }) else {
            XCTFail("Cannot find pending verification for email \(email)")
            return
        }

        let pendingVerification = pendingVerifications.remove(at: index)
        pendingVerification.completion(result)
    }
}
