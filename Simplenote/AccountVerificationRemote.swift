import Foundation

// MARK: - AccountVerificationRemote
//
class AccountVerificationRemote: Remote {
    /// Send verification request for specified email address
    ///

    private func verificationURLRequest(with email: String) -> URLRequest? {
        guard let base64EncodedEmail = email.data(using: .utf8)?.base64EncodedString(),
              let verificationURL = URL(string: SimplenoteConstants.verificationURL) else {
            return nil
        }

        var request = URLRequest(url: verificationURL.appendingPathComponent(base64EncodedEmail),
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: RemoteConstants.timeout)
        request.httpMethod = RemoteConstants.Method.GET

        return request
    }

    func verify(email: String, completion: @escaping (_ result: Result) -> Void) {
        guard let request = verificationURLRequest(with: email) else {
            return
        }

        performDataTask(with: request, completion: completion)
    }
}
