import XCTest
@testable import Simplenote

class MockAccountVerificationRemote: AccountRemote {
    private var pendingVerifications: [(email: String, completion: (Result<Data?, RemoteError>) -> Void)] = []

    override func verify(email: String, completion: @escaping (Result<Data?, RemoteError>) -> Void) {
        pendingVerifications.append((email, completion))
    }

    func processVerification(for email: String, with result: Result<Data?, RemoteError>) {
        guard let index = pendingVerifications.firstIndex(where: { $0.email == email }) else {
            XCTFail("Cannot find pending verification for email \(email)")
            return
        }

        let pendingVerification = pendingVerifications.remove(at: index)
        pendingVerification.completion(result)
    }
}
