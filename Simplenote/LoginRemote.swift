import Foundation

// MARK: - LoginRemote
//
class LoginRemote: Remote {

    func requestLoginEmail(email: String, completion: @escaping (_ result: Result<Data?, RemoteError>) -> Void) {
        let request = requestForLoginRequest(with: email)

        performDataTask(with: request, completion: completion)
    }

    func requestLoginConfirmation(authKey: String, authCode: String) async throws -> LoginConfirmationResponse {
        let request = requestForLoginCompletion(authKey: authKey, authCode: authCode)
        let response = try await performDataTask(with: request, type: LoginConfirmationResponse.self)
        
        return response
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

    func requestForLoginCompletion(authKey: String, authCode: String) -> URLRequest {
        let url = URL(string: SimplenoteConstants.loginCompletionURL)!

        return requestForURL(url, method: RemoteConstants.Method.POST, httpBody: [
            "auth_key": authKey,
            "auth_code": authCode
        ])
    }
}
