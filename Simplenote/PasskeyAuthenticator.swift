import Foundation
import AuthenticationServices

enum PasskeyError: Error {
    case couldNotRequestRegistrationChallenge
    case couldNotEncodeRegistrationChallenge
    case couldNotPrepareRegistrationData
    case authFailed
}

protocol PasskeyDelegate: AnyObject {
    func passkeyRegistrationSucceed()
    func passkeyRegistrationFailed(_ error: Error)
}

@objcMembers
class PasskeyAuthenticator: NSObject {
    typealias PresentationContext = ASAuthorizationControllerPresentationContextProviding
    let authenticator: SPAuthenticator
    let accountRemote: AccountRemote

    weak var delegate: PasskeyDelegate? = nil

    @objc
    init(authenticator: SPAuthenticator) {
        self.authenticator = authenticator
        self.accountRemote = AccountRemote()
    }

    // MARK: - Registration
    //
    func registerPasskey(for email: String, password: String, in presentationContext: PresentationContext) async throws {
        do {
            guard let data = try await accountRemote.requestChallengeResponseToCreatePasskey(forEmail: email, password: password) else {
                throw PasskeyError.couldNotRequestRegistrationChallenge
            }
            let passkeyChallenge = try JSONDecoder().decode(PasskeyRegistrationChallenge.self, from: data)
            attemptRegistration(with: passkeyChallenge, presentationContext: presentationContext)
        } catch {
            throw PasskeyError.couldNotEncodeRegistrationChallenge
        }
    }

    private func attemptRegistration(with passkeyChallenge: PasskeyRegistrationChallenge, presentationContext: PresentationContext) {
        guard let challengeData = passkeyChallenge.challengeData,
              let userID = passkeyChallenge.userID else {
            return
        }

        let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: passkeyChallenge.relayingPartyIdentifier)
        let platformKeyRequest = platformProvider.createCredentialRegistrationRequest(challenge: challengeData, name: passkeyChallenge.displayName, userID: userID)
        let authController = ASAuthorizationController(authorizationRequests: [platformKeyRequest])
        authController.delegate = self
        authController.presentationContextProvider = presentationContext
        authController.performRequests()
    }

    private func performPasskeyRegistration(with credential: ASAuthorizationPlatformPublicKeyCredentialRegistration) {
        guard let registrationObject = PasskeyRegistrationResponse(from: credential) else {
            delegate?.passkeyRegistrationFailed(PasskeyError.couldNotPrepareRegistrationData)
            return
        }

        Task {
            do {
                let data = try JSONEncoder().encode(registrationObject)
                try await accountRemote.registerCredential(with: data)
                delegate?.passkeyRegistrationSucceed()
            } catch {
                delegate?.passkeyRegistrationFailed(error)
            }
        }
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
        guard let data = try await AccountRemote().passkeyAuthChallenge(for: email) else {
            return nil
        }

        let challenge = try JSONDecoder().decode(PasskeyAuthChallenge.self, from: data)
        return challenge
    }

    private func performPasskeyAuthentication(with response: PasskeyAuthResponse) {
        let json = try! JSONEncoder().encode(response)

        Task { @MainActor in
            guard let response = try? await accountRemote.verifyPasskeyLogin(with: json),
                  let verifyResponse = try? JSONDecoder().decode(PasskeyVerifyResponse.self, from: response) else {
                self.delegate?.passkeyRegistrationFailed(PasskeyError.authFailed)
                return
            }

            authenticator.authenticate(withUsername: verifyResponse.username, token: verifyResponse.accessToken)
            self.delegate?.passkeyRegistrationSucceed()
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate
//
extension PasskeyAuthenticator: ASAuthorizationControllerDelegate {
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        if let delegate {
            delegate.passkeyRegistrationFailed(error)
        }
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {

        switch authorization.credential {
        case let credential as ASAuthorizationPlatformPublicKeyCredentialRegistration:
                performPasskeyRegistration(with: credential)

        case let credential as ASAuthorizationPlatformPublicKeyCredentialAssertion:
                let response = PasskeyAuthResponse(from: credential)

                performPasskeyAuthentication(with: response)
        default:
            break
        }
    }
}
