import Foundation

class PasskeyRemote: Remote {
    private func credentialCreationRequest(withEmail email: String, password: String) -> URLRequest {
        let params = [
            "email": email.lowercased(),
            "password": password,
            "webauthn": "true"
        ] as [String: Any]

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: SimplenoteConstants.passkeyCredentialCreationURL)
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        request.httpMethod = RemoteConstants.Method.POST
        request.httpBody = registrationBody(with: boundary, parameters: params)

        return request
    }

    private func registrationBody(with boundary: String, parameters: [String: Any]) -> Data {
        var body = String()

        for param in parameters {
            let paramName = param.key
            body += "--\(boundary)\r\n"
            body += "Content-Disposition:form-data; name=\"\(paramName)\""
            let paramValue = param.value as! String
            body += "\r\n\r\n\(paramValue)\r\n"
        }

        body += "--\(boundary)--\r\n"

        return Data(body.utf8)
    }

    func requestChallengeResponseToCreatePasskey(forEmail email: String, password: String) async throws -> Data? {
        let request = credentialCreationRequest(withEmail: email, password: password)

        return try await performDataTask(with: request)
    }

    private func requestForCredentialRegistration(withData data: Data) -> URLRequest {
        var urlRequest = URLRequest(url: SimplenoteConstants.passkeyRegistrationURL)
        urlRequest.httpMethod = RemoteConstants.Method.POST
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        urlRequest.httpBody = data

        return urlRequest
    }

    func registerCredential(with data: Data) async throws {
        let request = requestForCredentialRegistration(withData: data)
        try await _ = performDataTask(with: request)
    }

    private func authChallengeRequest(forEmail email: String?) -> URLRequest {
        let isAutoLogin = email == nil
        let url = isAutoLogin ?
        SimplenoteConstants.autoPasskeyAuthChallengeURL :
        SimplenoteConstants.passkeyAuthChallengeURL
        let method = isAutoLogin ? RemoteConstants.Method.GET : RemoteConstants.Method.POST

        var urlRequest =  URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let email {
            let body = [
                "email": email.lowercased()
            ]
            let json = try? JSONEncoder().encode(body)

            urlRequest.httpBody = json
        }

        return urlRequest
    }

    func authChallenge(for email: String?) async throws -> Data? {

        let request = authChallengeRequest(forEmail: email)
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
