import Foundation
import AuthenticationServices

class PasskeyRegistrator {
    let passkeyRemote: PasskeyRemote

    init(passkeyRemote: PasskeyRemote = PasskeyRemote()) {
        self.passkeyRemote = passkeyRemote
    }

    func requestChallenge(for email: String, password: String) async throws -> PasskeyRegistrationChallenge {
        do {
            guard let data = try await passkeyRemote.requestChallengeResponseToCreatePasskey(forEmail: email, password: password) else {
                throw PasskeyError.couldNotRequestRegistrationChallenge
            }
            return try JSONDecoder().decode(PasskeyRegistrationChallenge.self, from: data)
        } catch {
            throw PasskeyError.couldNotRequestRegistrationChallenge
        }
    }

    func attemptRegistration(with passkeyChallenge: PasskeyRegistrationChallenge, presentationContext: PresentationContext, delegate: ASAuthorizationControllerDelegate) {
        guard let challengeData = passkeyChallenge.challengeData,
              let userID = passkeyChallenge.userID else {
            return
        }

        let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: passkeyChallenge.relayingPartyIdentifier)
        let platformKeyRequest = platformProvider.createCredentialRegistrationRequest(challenge: challengeData, name: passkeyChallenge.displayName, userID: userID)
        let authController = ASAuthorizationController(authorizationRequests: [platformKeyRequest])
        authController.delegate = delegate
        authController.presentationContextProvider = presentationContext
        authController.performRequests()
    }
}
