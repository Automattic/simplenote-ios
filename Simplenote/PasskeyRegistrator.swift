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

    func requestChallenge(for email: String, password: String) async throws -> PasskeyRegistrationChallenge {
        userEmail = email
        do {
            guard let data = try await passkeyRemote.requestChallengeResponseToCreatePasskey(forEmail: email, password: password) else {
                throw PasskeyError.couldNotRequestRegistrationChallenge
            }
            return try JSONDecoder().decode(PasskeyRegistrationChallenge.self, from: data)
        } catch {
            throw PasskeyError.couldNotRequestRegistrationChallenge
        }
    }

    func attemptRegistration(with passkeyChallenge: PasskeyRegistrationChallenge, presentationContext: PresentationContext) async throws -> Data {
        guard let challengeData = passkeyChallenge.challengeData,
              let userID = passkeyChallenge.userID else {
            throw PasskeyError.couldNotRequestRegistrationChallenge
        }

        let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: passkeyChallenge.relayingPartyIdentifier)
        let platformKeyRequest = platformProvider.createCredentialRegistrationRequest(challenge: challengeData, name: passkeyChallenge.displayName, userID: userID)
        let authController = ASAuthorizationController(authorizationRequests: [platformKeyRequest])
        authController.delegate = internalAuthControllerDelegate
        authController.presentationContextProvider = presentationContext

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data, any Error>) in
            internalAuthControllerDelegate.onCompletion = { result in
                switch result {
                case .success(let credential):
                    do {
                        let registrationData = try self.registrationData(from: credential)
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

    private func registrationData(from credential: PublicKeyCredentialRegistration) throws -> Data {
        guard let registrationObject = PasskeyRegistrationResponse(from: credential, with: userEmail) else {
            throw PasskeyError.registrationFailed
        }

        return try JSONEncoder().encode(registrationObject)
    }
}
