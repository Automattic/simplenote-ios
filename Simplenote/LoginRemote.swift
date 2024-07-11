import Foundation

// MARK: - LoginRemote
//
class LoginRemote: Remote {

    func requestLoginEmail(email: String, completion: @escaping (_ result: Result<Data?, RemoteError>) -> Void) {
        let request = requestForLoginRequest(with: email)
        performDataTask(with: request, completion: completion)
    }

    func requestLoginConfirmation(email: String, authCode: String) async throws -> LoginConfirmationResponse {
        let request = requestForLoginCompletion(email: email, authCode: authCode)
        return try await performDataTask(with: request, type: LoginConfirmationResponse.self)
    }
}


// MARK: - LoginConfirmationResponse
//
struct LoginConfirmationResponse: Decodable {
    let username: String
    let syncToken: String
}


// MARK: - Private API(s)
//
private extension LoginRemote {

    func requestForLoginRequest(with email: String) -> URLRequest {
        let url = URL(string: SimplenoteConstants.loginRequestURL)!
        return requestForURL(url, method: RemoteConstants.Method.POST, httpBody: [
            "request_source": SimplenoteConstants.simplenotePlatformName,
            "username": email.lowercased()
        ])
    }

    func requestForLoginCompletion(username: String, authCode: String) -> URLRequest {
        let url = URL(string: SimplenoteConstants.loginCompletionURL)!
        return requestForURL(url, method: RemoteConstants.Method.POST, httpBody: [
            "auth_key": authKey,
            "username": username
        ])
    }
}
