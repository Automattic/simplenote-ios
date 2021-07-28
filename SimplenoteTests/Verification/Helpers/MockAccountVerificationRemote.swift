import XCTest
@testable import Simplenote

class MockAccountVerificationRemote: AccountRemote {
    private var pendingVerifications: [(email: String, completion: (Result<Int, RemoteError>) -> Void)] = []

    override func verify(email: String, completion: @escaping (Result<Int, RemoteError>) -> Void) {
        pendingVerifications.append((email, completion))
    }

    func processVerification(for email: String, with result: Result<Int, RemoteError>) {
        guard let index = pendingVerifications.firstIndex(where: { $0.email == email }) else {
            XCTFail("Cannot find pending verification for email \(email)")
            return
        }

        let pendingVerification = pendingVerifications.remove(at: index)
        pendingVerification.completion(result)
    }
}
