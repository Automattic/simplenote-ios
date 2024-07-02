import Foundation
import AuthenticationServices

enum PasskeyError: Error {
    case couldNotRequestRegistrationChallenge
}

typealias PresentationContext = ASAuthorizationControllerPresentationContextProviding

@objcMembers
class PasskeyAuthenticator: NSObject {
    let authenticator: SPAuthenticator
    let passkeyRemote = PasskeyRemote()

    var registrationEmail: String?

    @objc
    init(authenticator: SPAuthenticator) {
        self.authenticator = authenticator
    }

    // MARK: - Auth
    //
    func attemptPasskeyAuth(for email: String, in presentationContext: PresentationContext) async throws {
        guard let challenge = try await fetchAuthChallenge(for: email) else {
            return
        }

        let challengeData = try Data.decodeUrlSafeBase64(challenge.challenge)
        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: challenge.relayingParty)
        let request = provider.createCredentialAssertionRequest(challenge: challengeData)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = presentationContext
        controller.performRequests()
    }

    private func fetchAuthChallenge(for email: String) async throws -> PasskeyAuthChallenge? {
        guard let data = try await passkeyRemote.passkeyAuthChallenge(for: email) else {
            return nil
        }

        let challenge = try JSONDecoder().decode(PasskeyAuthChallenge.self, from: data)
        return challenge
    }

    private func performPasskeyAuthentication(with response: PasskeyAuthResponse) {
        Task { @MainActor in
            guard let json = try? JSONEncoder().encode(response),
                  let response = try? await passkeyRemote.verifyPasskeyLogin(with: json),
                  let verifyResponse = try? JSONDecoder().decode(PasskeyVerifyResponse.self, from: response) else {
                // TODO: handle auth failure
                return
            }

            authenticator.authenticate(withUsername: verifyResponse.username, token: verifyResponse.accessToken)
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate
//
extension PasskeyAuthenticator: ASAuthorizationControllerDelegate {
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        // TODO: handle error
        print(error.localizedDescription)
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {

        switch authorization.credential {

        case let credential as ASAuthorizationPlatformPublicKeyCredentialAssertion:
            let response = PasskeyAuthResponse(from: credential)

            performPasskeyAuthentication(with: response)
        default:
            break
        }
    }
}
