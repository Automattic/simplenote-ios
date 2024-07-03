import Foundation
import AuthenticationServices

enum PasskeyError: Error {
    case couldNotRequestRegistrationChallenge
    case counldNotFetchAuthChallenge
}

typealias PresentationContext = ASAuthorizationControllerPresentationContextProviding

class PasskeyAuthenticator: NSObject {
    let passkeyRemote: PasskeyRemote

    init(passkeyRemote: PasskeyRemote = PasskeyRemote()) {
        self.passkeyRemote = passkeyRemote
    }

    func attemptPasskeyAuth(challenge: PasskeyAuthChallenge?, in presentationContext: PresentationContext, delegate: ASAuthorizationControllerDelegate) async throws {
        guard let challenge else {
            throw PasskeyError.counldNotFetchAuthChallenge
        }

        let challengeData = try Data.decodeUrlSafeBase64(challenge.challenge)
        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: challenge.relayingParty)
        let request = provider.createCredentialAssertionRequest(challenge: challengeData)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = delegate
        controller.presentationContextProvider = presentationContext
        controller.performRequests()
    }

    func fetchAuthChallenge(for email: String) async throws -> PasskeyAuthChallenge? {
        guard let data = try await passkeyRemote.passkeyAuthChallenge(for: email) else {
            return nil
        }

        let challenge = try JSONDecoder().decode(PasskeyAuthChallenge.self, from: data)
        return challenge
    }
}
