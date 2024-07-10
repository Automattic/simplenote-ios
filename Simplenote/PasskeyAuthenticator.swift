import Foundation
import AuthenticationServices

enum PasskeyError: Error {
    case couldNotRequestRegistrationChallenge
    case couldNotFetchAuthChallenge
    case authFailed

    var localizedDescription: String {
        switch self {
        case .couldNotRequestRegistrationChallenge:
            return NSLocalizedString("Could not prepare an registration challenge", comment: "Error message that registering passkeys could not receive needed challeng")
        case .couldNotFetchAuthChallenge:
            return NSLocalizedString("Could not prepare an authorization challenge", comment: "Error message that authorizing passkeys could not receive needed challeng")
        case .authFailed:
            return NSLocalizedString("Authorization Failed", comment: "Error message that passkey authorization failed")
        }
    }
}

typealias PresentationContext = ASAuthorizationControllerPresentationContextProviding

class PasskeyAuthenticator: NSObject {
    let passkeyRemote: PasskeyRemote

    init(passkeyRemote: PasskeyRemote = PasskeyRemote()) {
        self.passkeyRemote = passkeyRemote
    }

    func attemptPasskeyAuth(challenge: PasskeyAuthChallenge?, in presentationContext: PresentationContext, delegate: ASAuthorizationControllerDelegate) async throws {
        guard let challenge else {
            throw PasskeyError.couldNotFetchAuthChallenge
        }

        let challengeData = try Data.decodeUrlSafeBase64(challenge.challenge)
        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: challenge.relayingParty)
        let request = provider.createCredentialAssertionRequest(challenge: challengeData)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = delegate
        controller.presentationContextProvider = presentationContext
        controller.performRequests()
    }

    @available(iOS 16.0, *)
    func prepareAutoAuthRequest(for challenge: PasskeyAuthChallenge?, in presentationContext: PresentationContext, delegate: ASAuthorizationControllerDelegate) throws {
        guard let challenge else {
            throw PasskeyError.couldNotFetchAuthChallenge
        }

        let challengeData = try Data.decodeUrlSafeBase64(challenge.challenge)
        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: challenge.relayingParty)
        let request = provider.createCredentialAssertionRequest(challenge: challengeData)
        

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = delegate
        controller.presentationContextProvider = presentationContext
        controller.performAutoFillAssistedRequests()
    }

    func fetchAuthChallenge(for email: String? = nil) async throws -> PasskeyAuthChallenge? {
        guard let data = try await passkeyRemote.authChallenge(for: email) else {
            return nil
        }

        let challenge = try JSONDecoder().decode(PasskeyAuthChallenge.self, from: data)
        return challenge
    }
}
