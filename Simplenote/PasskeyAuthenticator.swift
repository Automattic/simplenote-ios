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

class PasskeyAuthControllerDelegate: NSObject, ASAuthorizationControllerDelegate {

    var onCompletion: ((Result<PasskeyVerifyResponse, Error>) -> Void)?

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        onCompletion?(.failure(error))
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion else {
            onCompletion?(.failure(PasskeyError.authFailed))
            return
        }

        Task {
            do {
                let response = PasskeyAuthResponse(from: credential)
                let verify = try await performPasskeyAuthentication(with: response)
                onCompletion?(.success(verify))
            } catch {
                onCompletion?(.failure(error))
            }
        }
    }

    private func performPasskeyAuthentication(with response: PasskeyAuthResponse) async throws -> PasskeyVerifyResponse {
        guard let json = try? JSONEncoder().encode(response),
              let response = try? await PasskeyRemote().verifyPasskeyLogin(with: json),
              let verifyResponse = try? JSONDecoder().decode(PasskeyVerifyResponse.self, from: response) else {
            throw PasskeyError.authFailed
        }

        return verifyResponse
    }
}

typealias PresentationContext = ASAuthorizationControllerPresentationContextProviding
typealias PublicKeyCredentialAssertion = ASAuthorizationPlatformPublicKeyCredentialAssertion

class PasskeyAuthenticator: NSObject {
    let passkeyRemote: PasskeyRemote
    let internalAuthControllerDelegate: PasskeyAuthControllerDelegate

    init(passkeyRemote: PasskeyRemote = PasskeyRemote(), authControllerDelegate: PasskeyAuthControllerDelegate = .init()) {
        self.passkeyRemote = passkeyRemote
        self.internalAuthControllerDelegate = authControllerDelegate
    }

    func attemptPasskeyAuth(challenge: PasskeyAuthChallenge?, in presentationContext: PresentationContext, delegate: ASAuthorizationControllerDelegate) async throws -> PasskeyVerifyResponse {
        guard let challenge else {
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
                case .success(let verify):
                    continuation.resume(returning: verify)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }

            controller.performRequests()
        }
    }

    func fetchAuthChallenge(for email: String) async throws -> PasskeyAuthChallenge? {
        guard let data = try await passkeyRemote.passkeyAuthChallenge(for: email) else {
            return nil
        }

        let challenge = try JSONDecoder().decode(PasskeyAuthChallenge.self, from: data)
        return challenge
    }
}
