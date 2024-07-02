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

    // MARK: - Passkeys
    //

    private func passkeyAuthChallengeRequest(forEmail email: String) -> URLRequest {
        var urlRequest = URLRequest(url: SimplenoteConstants.passkeyAuthChallengeURL)
        urlRequest.httpMethod = RemoteConstants.Method.POST
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = [
            "email": email.lowercased()
        ]
        let json = try? JSONEncoder().encode(body)

        urlRequest.httpBody = json

        return urlRequest
    }

    func passkeyAuthChallenge(for email: String) async throws -> Data? {
        let request = passkeyAuthChallengeRequest(forEmail: email)
        return try await performDataTask(with: request)
    }

    private func verifyPassKeyRequest(with data: Data) -> URLRequest {
        var urlRequest = URLRequest(url: SimplenoteConstants.verifyPasskeyAuthChallengeURL)
        urlRequest.httpMethod = RemoteConstants.Method.POST
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = data

        return urlRequest
    }

    func verifyPasskeyLogin(with data: Data) async throws -> Data? {
        let request = verifyPassKeyRequest(with: data)
        return try await performDataTask(with: request)
    }
}
