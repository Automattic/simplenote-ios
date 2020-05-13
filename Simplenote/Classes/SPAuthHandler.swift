import Foundation
import OnePasswordExtension
import SafariServices


// MARK: - SPAuthHandler
//
class SPAuthHandler {

    /// Simperium Authenticator
    ///
    private let simperiumService: SPAuthenticator

    /// OnePassword Extension convenience property
    ///
    private var onePasswordService: OnePasswordExtension {
        return OnePasswordExtension.shared()
    }

    /// Indicates if OnePassword is available.
    ///
    var isOnePasswordAvailable: Bool {
        return OnePasswordExtension.shared().isAppExtensionAvailable()
    }


    /// Designated Initializer.
    ///
    /// - Parameter simperiumService: Reference to a valid SPAuthenticator instance.
    ///
    init(simperiumService: SPAuthenticator) {
        self.simperiumService = simperiumService
    }


    /// Presents the OnePassword Extension for Login.
    ///
    /// - Note: Errors are mapped into SPAuthError.
    ///
    /// - Parameters:
    ///     - presenter: Source UIViewController from which the extension should be presented.
    ///     - sender: The sender which triggers the share sheet to show.
    ///     - onCompletion: Closure to be executed on completion.
    ///
    func findOnePasswordLogin(presenter: UIViewController, sender: Any, onCompletion: @escaping (String?, String?, SPAuthError?) -> Void) {
        onePasswordService.findLogin(forURLString: kOnePasswordSimplenoteURL, for: presenter, sender: sender) { (dictionary, error) in
            guard let username = dictionary?[AppExtensionUsernameKey] as? String,
                let password = dictionary?[AppExtensionPasswordKey] as? String
                else {
                    let wrappedError = SPAuthError(onePasswordError: error)
                    onCompletion(nil, nil, wrappedError)
                    return
            }

            onCompletion(username, password, nil)
        }
    }


    /// Presents the OnePassword Extension for Signup purposes: The user will be allowed to store a given set of credentials.
    ///
    /// - Note: Errors are mapped into SPAuthError.
    ///
    /// - Parameters:
    ///     - presenter: Source UIViewController from which the extension should be presented.
    ///     - sender: The sender which triggers the share sheet to show.
    ///     - username: Simperium Username
    ///     - password: Simperium Password
    ///     - onCompletion: Closure to be executed on completion.
    ///
    func saveLoginToOnePassword(presenter: UIViewController, sender: Any, username: String, password: String, onCompletion: @escaping (String?, String?, SPAuthError?) -> Void) {
        let details = [
            AppExtensionTitleKey: kOnePasswordSimplenoteTitle,
            AppExtensionUsernameKey: username,
            AppExtensionPasswordKey: password
        ]

        let options = [
            AppExtensionGeneratedPasswordMinLengthKey: kOnePasswordGeneratedMinLength,
            AppExtensionGeneratedPasswordMaxLengthKey: kOnePasswordGeneratedMaxLength
        ]

        onePasswordService.storeLogin(forURLString: kOnePasswordSimplenoteURL, loginDetails: details, passwordGenerationOptions: options, for: presenter, sender: sender) { (dictionary, error) in
            guard let username = dictionary?[AppExtensionUsernameKey] as? String,
                let password = dictionary?[AppExtensionPasswordKey] as? String
                else {
                    let wrappedError = SPAuthError(onePasswordError: error)
                    onCompletion(nil, nil, wrappedError)
                    return
            }

            onCompletion(username, password, nil)
        }
    }


    /// Authenticates against the Simperium Backend.
    ///
    /// - Note: Errors are mapped into SPAuthError Instances
    ///
    /// - Parameters:
    ///     - username: Simperium Username
    ///     - password: Simperium Password
    ///     - onCompletion: Closure to be executed on completion
    ///
    func loginWithCredentials(username: String, password: String, onCompletion: @escaping (SPAuthError?) -> Void) {
        simperiumService.authenticate(withUsername: username, password: password, success: {
            onCompletion(nil)
        }, failure: { (responseCode, _) in
            let wrappedError = SPAuthError(simperiumLoginErrorCode: Int(responseCode))
            onCompletion(wrappedError)
        })
    }


    /// Validates a set of credentials against the Simperium Backend.
    ///
    /// - Note: This API is meant to be used to verify an unsecured set of credentials, before presenting the Reset Password UI.
    ///
    /// - Parameters:
    ///     - username: Simperium Username
    ///     - password: Simperium Password
    ///     - onCompletion: Closure to be executed on completion
    ///
    func validateWithCredentials(username: String, password: String, onCompletion: @escaping (SPAuthError?) -> Void) {
        simperiumService.validate(withUsername: username, password: password, success: {
            onCompletion(nil)
        }, failure: { (responseCode, _) in
            let wrappedError = SPAuthError(simperiumLoginErrorCode: Int(responseCode))
            onCompletion(wrappedError)
        })
    }


    /// Registers a new user in the Simperium Backend.
    ///
    /// - Note: Errors are mapped into SPAuthError Instances
    ///
    /// - Parameters:
    ///     - username: Simperium Username
    ///     - password: Simperium Password
    ///     - onCompletion: Closure to be executed on completion
    ///
    func signupWithCredentials(username: String, password: String, onCompletion: @escaping (SPAuthError?) -> Void) {
        simperiumService.create(withUsername: username, password: password, success: {
            onCompletion(nil)
        }, failure: { (responseCode, _) in
            let wrappedError = SPAuthError(simperiumSignupErrorCode: Int(responseCode))
            onCompletion(wrappedError)
        })
    }


    /// Presents the Password Reset (Web) Interface
    ///
    func presentPasswordReset(from sourceViewController: UIViewController, username: String) {
        let escapedUsername = username.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? username
        guard let targetURL = URL(string: kSimperiumForgotPasswordURL + "?email=" + escapedUsername) else {
            return
        }

        let safariViewController = SFSafariViewController(url: targetURL)
        safariViewController.modalPresentationStyle = .overFullScreen
        sourceViewController.present(safariViewController, animated: true, completion: nil)
    }
}
