import Foundation

class PasskeyRemote: Remote {
    private func passkeyCredentialCreationRequest(withEmail email: String, password: String) -> URLRequest {
        let params = [
            "email": email.lowercased(),
            "password": password,
            "webauthn": "true"
        ] as [String: Any]

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: SimplenoteConstants.passkeyCredentialCreationURL)
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        request.httpMethod = RemoteConstants.Method.POST
        request.httpBody = passkeyRegistrationBody(with: boundary, parameters: params)

        return request
    }

    private func passkeyRegistrationBody(with boundary: String, parameters: [String: Any]) -> Data {
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

    func requestChallengeResponseToCreatePasskey(forEmail email: String, password: String) async throws -> PasskeyRegistrationChallenge {
        let request = passkeyCredentialCreationRequest(withEmail: email, password: password)
        let data = try await performDataTask(with: request)

        return try JSONDecoder().decode(PasskeyRegistrationChallenge.self, from: data)
    }

    private func requestForPasskeyCredentialRegistration(withData data: Data) -> URLRequest {
        var urlRequest = URLRequest(url: SimplenoteConstants.passkeyRegistrationURL)
        urlRequest.httpMethod = RemoteConstants.Method.POST
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        urlRequest.httpBody = data

        return urlRequest
    }

    func registerCredential(with response: PasskeyRegistrationResponse) async throws {
        let data = try JSONEncoder().encode(response)
        let request = requestForPasskeyCredentialRegistration(withData: data)
        try await _ = performDataTask(with: request)
    }

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

    func passkeyAuthChallenge(for email: String) async throws -> PasskeyAuthChallenge {
        let request = passkeyAuthChallengeRequest(forEmail: email)
        let data = try await performDataTask(with: request)

        return try JSONDecoder().decode(PasskeyAuthChallenge.self, from: data)
    }

    private func verifyPassKeyRequest(with data: Data) -> URLRequest {
        var urlRequest = URLRequest(url: SimplenoteConstants.verifyPasskeyAuthChallengeURL)
        urlRequest.httpMethod = RemoteConstants.Method.POST
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = data

        return urlRequest
    }

    func verifyPasskeyLogin(with response: PasskeyAuthResponse) async throws -> PasskeyVerifyResponse {
        guard let data = try? JSONEncoder().encode(response) else {
            throw PasskeyError.authFailed
        }

        let request = verifyPassKeyRequest(with: data)
        let verify = try await performDataTask(with: request)

        return try JSONDecoder().decode(PasskeyVerifyResponse.self, from: verify)
    }
}
