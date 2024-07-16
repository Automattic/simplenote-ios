import Foundation
import AuthenticationServices

struct PasskeyRegistrationResponse: Encodable {
    struct Response: Encodable {
        let clientDataJSON: String
        let attestationObject: String
    }

    private let email: String
    private let id: String
    private let rawId: String
    private let type: String
    private let response: PasskeyRegistrationResponse.Response

    init(from credentialRegistration: ASAuthorizationPlatformPublicKeyCredentialRegistration, with email: String?) throws {
        guard let email,
        let clientJson = Self.prepareJSON(from: credentialRegistration.rawClientDataJSON),
        let rawAttestationObject = credentialRegistration.rawAttestationObject else {
            throw PasskeyError.registrationFailed
        }

        let idString = credentialRegistration.credentialID.base64EncodedString().toBase64url()
        let response = Response(clientDataJSON: clientJson.base64EncodedString(), attestationObject: rawAttestationObject.base64EncodedString())

        self.email = email
        self.id = idString
        self.rawId = idString
        self.type = "public-key"
        self.response = response
    }

    private static func prepareJSON(from data: Data) -> Data? {
        guard var json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let base64challenge = json["challenge"] as? String,
              let challengeData = Data(base64Encoded: base64challenge + "="),
              let challenge = String(data: challengeData, encoding: .utf8) else {
            return nil
        }

        json["challenge"] = challenge

        return try? JSONSerialization.data(withJSONObject: json)
    }
}
