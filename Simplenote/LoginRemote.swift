import Foundation

// MARK: - LoginRemote
//
class LoginRemote: Remote {

    func requestLoginEmail(email: String, completion: @escaping (_ result: Result<Data?, RemoteError>) -> Void) {
        let request = requestForLoginRequest(with: email)

        performDataTask(with: request, completion: completion)
    }

    func requestSyncToken(email: String, authCode: String) async throws -> String {
        let request = requestForLoginCompletion(email: email, authCode: authCode)
        let response = try await performDataTask(with: request, type: LoginConfirmationResponse.self)
        
        return response.syncToken
    }
}


// MARK: - LoginConfirmationResponse
//
struct LoginConfirmationResponse: Decodable {
    let syncToken: String
}


// MARK: - Private API(s)
//
private extension LoginRemote {

    func requestForLoginRequest(with email: String) -> URLRequest {
        let url = URL(string: SimplenoteConstants.loginRequestURL)!

        return requestForURL(url, method: RemoteConstants.Method.POST, httpBody: [
            "username": email.lowercased()
        ])
    }

    func requestForLoginCompletion(email: String, authCode: String) -> URLRequest {
        let url = URL(string: SimplenoteConstants.loginCompletionURL)!

        return requestForURL(url, method: RemoteConstants.Method.POST, httpBody: [
            "username": email.lowercased(),
            "auth_code": authCode
        ])
    }
}
