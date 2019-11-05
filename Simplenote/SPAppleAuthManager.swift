import Foundation
import AuthenticationServices


// MARK: - AppleAuthenticationManagerContextProvider
//
@available(iOS 13.0, *)
protocol SPAppleAuthManagerContextProvider: NSObject {
    func presentationAnchor(for controller: SPAppleAuthManager) -> UIWindow
}


// MARK: - SPAppleAuthManager: Wraps all of the SIWA SDK interactions
//
@available(iOS 13.0, *)
class SPAppleAuthManager: NSObject {

    /// Ladies and gentlemen, this is yet another singleton
    ///
    static let shared = SPAppleAuthManager()

    /// Callback Map!
    ///
    private var callbackMap = [ObjectIdentifier: (ASAuthorizationAppleIDCredential?, Error?) -> Void]()

    /// UIWindow reference provider
    ///
    weak var presentationContextProvider: SPAppleAuthManagerContextProvider?



    /// Presents the SIWA Interface from a given UIWindow instance
    ///
    func presentSignInWithApple(onCompletion: @escaping ((ASAuthorizationAppleIDCredential?, Error?) -> Void)) {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()

        storeCallback(for: controller, callback: onCompletion)
    }


    /// Presents the SIWA Interface whenever an account was already created.
    ///
    func presentExistingAccountSetupFlows(onCompletion: @escaping ((ASAuthorizationAppleIDCredential?, Error?) -> Void)) {
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                               ASAuthorizationPasswordProvider().createRequest()]

        let controller = ASAuthorizationController(authorizationRequests: requests)
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()

        storeCallback(for: controller, callback: onCompletion)
    }


    /// Checks the state of a given Apple UserID
    ///
    func checkCredentails(for aaplUserID: String, onCompletion: @escaping (ASAuthorizationAppleIDProvider.CredentialState, Error?) -> Void) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: aaplUserID, completion: onCompletion)
    }
}


// MARK: - Private Methods
//
@available(iOS 13.0, *)
private extension SPAppleAuthManager {

    func storeCallback(for controller: ASAuthorizationController, callback: @escaping ((ASAuthorizationAppleIDCredential?, Error?) -> Void)) {
        callbackMap[ObjectIdentifier(controller)] = callback
    }

    func callbackForController(_ controller: ASAuthorizationController) -> ((ASAuthorizationAppleIDCredential?, Error?) -> Void)? {
        let key = ObjectIdentifier(controller)
        guard let callback = callbackMap[key] else {
            return nil
        }

        callbackMap.removeValue(forKey: key)
        return callback
    }
}


// MARK: - ASAuthorizationControllerDelegate
///
@available(iOS 13.0, *)
extension SPAppleAuthManager: ASAuthorizationControllerDelegate {

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credentials = authorization.credential as? ASAuthorizationAppleIDCredential else {
            fatalError("AppleAuthManager only supports AppleID Requests")
        }

        callbackForController(controller)?(credentials, nil)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        callbackForController(controller)?(nil, error)
    }
}


// MARK: - ASAuthorizationControllerPresentationContextProviding
//
@available(iOS 13.0, *)
extension SPAppleAuthManager: ASAuthorizationControllerPresentationContextProviding {

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = presentationContextProvider?.presentationAnchor(for: self) else {
            fatalError("AppleAuthManager needs a window!")
        }

        return window
    }
}
