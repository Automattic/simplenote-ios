import Foundation

// MARK: - AccountVerificationRemote
//
class AccountRemote: Remote {
    // MARK: Performing tasks

    /// Send verification request for specified email address
    ///
    func verify(email: String, completion: @escaping (_ result: Result<Data?, RemoteError>) -> Void) {
        let request = verificationURLRequest(with: email)

        performDataTask(with: request, completion: completion)
    }

    /// Send account deletion request for user
    ///
    func requestDelete(_ user: SPUser, completion: @escaping (_ result: Result<Data?, RemoteError>) -> Void) {
        let request = deleteRequest(with: user)
        performDataTask(with: request, completion: completion)
    }

    // MARK: URL Requests

    private func verificationURLRequest(with email: String) -> URLRequest {
        let base64EncodedEmail = email.data(using: .utf8)!.base64EncodedString()
        let verificationURL = URL(string: SimplenoteConstants.verificationURL)!

        var request = URLRequest(url: verificationURL.appendingPathComponent(base64EncodedEmail),
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: RemoteConstants.timeout)
        request.httpMethod = RemoteConstants.Method.GET

        return request
    }

    private func deleteRequest(with user: SPUser) -> URLRequest {
        let url = URL(string: SimplenoteConstants.accountDeletionURL)!

        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: RemoteConstants.timeout)
        request.httpMethod = RemoteConstants.Method.POST
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = [
            "username": user.email.lowercased(),
            "token": user.authToken
        ]
        request.httpBody = try? JSONEncoder().encode(body)

        return request
    }
}
