import Foundation
import AuthenticationServices

enum PasskeyError: Error {
    case couldNotRequestRegistrationChallenge
    case couldNotFetchAuthChallenge
    case authFailed
    case registrationFailed

    var localizedDescription: String {
        switch self {
        case .couldNotRequestRegistrationChallenge:
            return NSLocalizedString("Could not prepare an registration challenge", comment: "Error message that registering passkeys could not receive needed challeng")
        case .couldNotFetchAuthChallenge:
            return NSLocalizedString("Could not prepare an authorization challenge", comment: "Error message that authorizing passkeys could not receive needed challeng")
        case .authFailed:
            return NSLocalizedString("Authorization Failed", comment: "Error message that passkey authorization failed")
        case .registrationFailed:
            return NSLocalizedString("Registration Failed", comment: "Error message that passkey registration failed")
        }
    }
}

class PasskeyAuthControllerDelegate: NSObject, ASAuthorizationControllerDelegate {

    var onCompletion: ((Result<PasskeyAuthResponse, Error>) -> Void)?

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        onCompletion?(.failure(error))
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion else {
            onCompletion?(.failure(PasskeyError.authFailed))
            return
        }

        let response = PasskeyAuthResponse(from: credential)
        onCompletion?(.success(response))
    }
}

typealias PresentationContext = ASAuthorizationControllerPresentationContextProviding
typealias PublicKeyCredentialAssertion = ASAuthorizationPlatformPublicKeyCredentialAssertion

class PasskeyAuthenticator: NSObject {
    private let passkeyRemote: PasskeyRemote
    private let internalAuthControllerDelegate: PasskeyAuthControllerDelegate

    init(passkeyRemote: PasskeyRemote = PasskeyRemote(), authControllerDelegate: PasskeyAuthControllerDelegate = .init()) {
        self.passkeyRemote = passkeyRemote
        self.internalAuthControllerDelegate = authControllerDelegate
    }

    fileprivate func extractedFunc(_ response: PasskeyAuthResponse) -> Task<(), Never> {
        return Task {
            do {
                let verify = try await self.performPasskeyAuthentication(with: response)
                continuation.resume(returning: verify)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    func attemptPasskeyAuth(for email: String, in presentationContext: PresentationContext) async throws -> PasskeyVerifyResponse {
        guard let challenge = try await passkeyRemote.passkeyAuthChallenge(for: email) else {
            throw PasskeyError.couldNotFetchAuthChallenge
        }

        let challengeData = try Data.decodeUrlSafeBase64(challenge.challenge)
        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: challenge.relayingParty)
        let request = provider.createCredentialAssertionRequest(challenge: challengeData)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = internalAuthControllerDelegate
        controller.presentationContextProvider = presentationContext

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<PasskeyVerifyResponse, any Error>) in
            internalAuthControllerDelegate.onCompletion = { result in
                switch result {
                case .success(let response):
                    extractedFunc(response)

                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }

            controller.performRequests()
        }
    }

    private func performPasskeyAuthentication(with response: PasskeyAuthResponse) async throws -> PasskeyVerifyResponse {
        guard let json = try? JSONEncoder().encode(response),
              let response = try? await PasskeyRemote().verifyPasskeyLogin(with: json) else {
            throw PasskeyError.authFailed
        }

        return response
    }
}
