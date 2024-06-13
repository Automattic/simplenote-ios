//
//  PasskeyAuthenticator.swift
//  Simplenote
//
//  Created by Charlie Scheer on 6/13/24.
//  Copyright © 2024 Automattic. All rights reserved.
//

import Foundation
import AuthenticationServices

enum PasskeyError: Error {
    case couldNotRequestRegistrationChallenge
}

@objcMembers
class PasskeyAuthenticator: NSObject {
    typealias PresentationContext = ASAuthorizationControllerPresentationContextProviding
    let authenticator: SPAuthenticator
    let accountRemote: AccountRemote

    @objc
    init(authenticator: SPAuthenticator) {
        self.authenticator = authenticator
        self.accountRemote = AccountRemote()
    }

    func registerPasskey(for email: String, password: String, in presentationContext: PresentationContext) async throws {
        do {
            guard let data = try await accountRemote.requestChallengeResponseToCreatePasskey(forEmail: email, password: password) else {
                throw PasskeyError.couldNotRequestRegistrationChallenge
            }
            let passkeyChallenge = try JSONDecoder().decode(PasskeyChallenge.self, from: data)
            attemptRegistration(with: passkeyChallenge, presentationContext: presentationContext)
        } catch {
            throw PasskeyError.couldNotRequestRegistrationChallenge
        }
    }

    private func attemptRegistration(with passkeyChallenge: PasskeyChallenge, presentationContext: PresentationContext) {
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
}

extension PasskeyAuthenticator: ASAuthorizationControllerDelegate {
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        // TODO: handle error
        print(error.localizedDescription)
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {

        if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialRegistration {
            guard let registrationObject = PasskeyRegistration(from: credential) else {
                //TODO: Should handle error
                return
            }

            Task {
                do {
                    let data = try JSONEncoder().encode(registrationObject)
                    try await accountRemote.registerCredential(with: data)
                } catch {
                    //TODO: Display error
                }
            }
        }
    }
}
