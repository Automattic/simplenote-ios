import Foundation
import AuthenticationServices

class PasskeyRegistrationControllerDelegate: NSObject, ASAuthorizationControllerDelegate {
    var onCompletion: ((Result<PublicKeyCredentialRegistration, Error>) -> Void)?

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        onCompletion?(.failure(error))
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? PublicKeyCredentialRegistration else {
            onCompletion?(.failure(PasskeyError.couldNotRequestRegistrationChallenge))
            return
        }

        onCompletion?(.success(credential))
    }
}

typealias PublicKeyCredentialRegistration = ASAuthorizationPlatformPublicKeyCredentialRegistration

class PasskeyRegistrator {
    private let passkeyRemote: PasskeyRemote
    private let internalAuthControllerDelegate: PasskeyRegistrationControllerDelegate
    private var userEmail: String? = nil

    init(passkeyRemote: PasskeyRemote = PasskeyRemote(), registrationDelegate: PasskeyRegistrationControllerDelegate = .init()) {
        self.passkeyRemote = passkeyRemote
        self.internalAuthControllerDelegate = registrationDelegate
    }

    func attemptPasskeyRegistration(for email: String, password: String, presentationContext: PresentationContext) async throws {
        let challenge = try await requestChallenge(for: email, password: password)
        let registrationResponse = try await attemptRegistration(with: challenge, presentationContext: presentationContext)
        try await passkeyRemote.registerCredential(with: registrationResponse)
    }

    private func requestChallenge(for email: String, password: String) async throws -> PasskeyRegistrationChallenge {
        userEmail = email
        do {
            return try await passkeyRemote.requestChallengeResponseToCreatePasskey(forEmail: email, password: password)
        } catch {
            throw PasskeyError.couldNotRequestRegistrationChallenge
        }
    }

    private func attemptRegistration(with passkeyChallenge: PasskeyRegistrationChallenge, presentationContext: PresentationContext) async throws -> PasskeyRegistrationResponse {
        guard let challengeData = passkeyChallenge.challengeData,
              let userID = passkeyChallenge.userID else {
            throw PasskeyError.couldNotRequestRegistrationChallenge
        }

        let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: passkeyChallenge.relayingPartyIdentifier)
        let platformKeyRequest = platformProvider.createCredentialRegistrationRequest(challenge: challengeData, name: passkeyChallenge.displayName, userID: userID)
        let authController = ASAuthorizationController(authorizationRequests: [platformKeyRequest])
        authController.delegate = internalAuthControllerDelegate
        authController.presentationContextProvider = presentationContext

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<PasskeyRegistrationResponse, any Error>) in
            internalAuthControllerDelegate.onCompletion = { [weak self] result in
                guard let self else {
                    continuation.resume(throwing: PasskeyError.registrationFailed)
                    return
                }

                switch result {
                case .success(let credential):
                    do {
                        let registrationData = try PasskeyRegistrationResponse(from: credential, with: userEmail)
                        continuation.resume(returning: registrationData)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }

            authController.performRequests()
        }
    }
}
