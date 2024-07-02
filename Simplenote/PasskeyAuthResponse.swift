import Foundation
import AuthenticationServices

struct PasskeyAuthResponse: Codable {
    let id: String
    let rawId: String
    let response: Response
    var type: String = "public-key"

    init(from credential: ASAuthorizationPlatformPublicKeyCredentialAssertion) {
        self.id = credential.credentialID.base64EncodedString().toBase64url()
        self.rawId = credential.credentialID.base64EncodedString().toBase64url()
        self.response = PasskeyAuthResponse.Response(clientDataJSON: credential.rawClientDataJSON.base64EncodedString(), authenticatorData: credential.rawAuthenticatorData.base64EncodedString(), signature: credential.signature.base64EncodedString(), userHandle: credential.userID.base64EncodedString())
    }

    struct Response: Codable {
        let clientDataJSON: String
        let authenticatorData: String
        let signature: String
        let userHandle: String
    }
}
