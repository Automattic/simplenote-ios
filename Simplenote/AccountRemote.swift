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
    private func passkeyCredentialCreationRequest(withEmail email: String, password: String) -> URLRequest {
        let params = [
            "email": email.lowercased(),
            "password": password,
            "webauthn": "true"
        ] as [String: Any]

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: URL(string: "https://passkey-dev-dot-simple-note-hrd.appspot.com/api2/login")!, timeoutInterval: Double.infinity)
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = body(with: boundary, parameters: params)

        return request
    }

    private func body(with boundary: String, parameters: [String: Any]) -> Data {
        var body = Data()

        for param in parameters {
            let paramName = param.key
            body += Data("--\(boundary)\r\n".utf8)
            body += Data("Content-Disposition:form-data; name=\"\(paramName)\"".utf8)
            let paramValue = param.value as! String
            body += Data("\r\n\r\n\(paramValue)\r\n".utf8)
        }

        body += Data("--\(boundary)--\r\n".utf8)

        return body
    }

    func requestChallengeResponseToCreatePasskey(forEmail email: String, password: String) async throws -> Data? {
        let request = passkeyCredentialCreationRequest(withEmail: email, password: password)

        return try await performDataTask(with: request)
    }
}
