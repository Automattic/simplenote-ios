import Foundation
import AuthenticationServices


// MARK: - AppleAuthenticationManagerDelegate
//
@available(iOS 13.0, *)
protocol AppleAuthenticationManagerDelegate: NSObject {
    func authenticationManager(manager: SPAppleAuthManager, didCompleteWithCredentials credentials: ASAuthorizationAppleIDCredential)
    func authenticationManager(manager: SPAppleAuthManager, didCompleteWithError error: Error)
}


// MARK: - SPAppleAuthManager: Encapsulates all of the SIWA SDK interactions
//
@available(iOS 13.0, *)
class SPAppleAuthManager: NSObject {

    /// Presentation Context
    ///
    private var window: UIWindow?

    /// Delegate to be notified of (several) events
    ///
    weak var delegate: AppleAuthenticationManagerDelegate?


    /// Presents the SIWA Interface from a given UIWindow instance
    ///
    func presentSignInWithApple(from window: UIWindow) {
        assert(delegate != nil)

        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()

        self.window = window
    }


    /// Checks the state of a given Apple UserID
    ///
    func checkCredentails(for aaplUserID: String, onCompletion: @escaping (ASAuthorizationAppleIDProvider.CredentialState, Error?) -> Void) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: aaplUserID, completion: onCompletion)
    }
}


// MARK: - ASAuthorizationControllerDelegate Conformance
///
@available(iOS 13.0, *)
extension SPAppleAuthManager: ASAuthorizationControllerDelegate {

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credentials = authorization.credential as? ASAuthorizationAppleIDCredential else {
            fatalError("AppleAuthManager only supports AppleID Requests")
        }

        delegate?.authenticationManager(manager: self, didCompleteWithCredentials: credentials)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        delegate?.authenticationManager(manager: self, didCompleteWithError: error)
    }
}


// MARK: - ASAuthorizationControllerPresentationContextProviding Conformance
//
@available(iOS 13.0, *)
extension SPAppleAuthManager: ASAuthorizationControllerPresentationContextProviding {

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = window else {
            fatalError("AppleAuthManager needs a window!")
        }

        return window
    }
}
