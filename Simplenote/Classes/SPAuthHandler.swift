import Foundation
import SafariServices

// MARK: - SPAuthHandler
//
class SPAuthHandler {

    /// Simperium Authenticator
    ///
    private let simperiumService: SPAuthenticator

    /// Designated Initializer.
    ///
    /// - Parameter simperiumService: Reference to a valid SPAuthenticator instance.
    ///
    init(simperiumService: SPAuthenticator) {
        self.simperiumService = simperiumService
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
        }, failure: { (statusCode, response, error) in
            let error = SPAuthError(loginErrorCode: statusCode, response: response, error: error)
            onCompletion(error)
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
        }, failure: { (statusCode, response, error) in
            let error = SPAuthError(loginErrorCode: statusCode, response: response, error: error)
            onCompletion(error)
        })
    }

    /// Requests an Authentication Email
    ///
    func requestLoginEmail(username: String, onCompletion: @escaping (SPAuthError?) -> Void) {
        let remote = LoginRemote()
        remote.requestLoginEmail(email: username) { (result) in
            switch result {
            case .success:
                onCompletion(nil)
            case .failure(let error):
                onCompletion(self.authenticationError(for: error))
            }
        }
    }

    /// Performs LogIn the User with an Authentication Code
    ///
    @MainActor
    func loginWithCode(username: String, code: String) async throws {
        let remote = LoginRemote()
        do {
            let confirmation = try await remote.requestLoginConfirmation(email: username, authCode: code.uppercased())
            simperiumService.authenticate(withUsername: confirmation.username, token: confirmation.syncToken)
            
        } catch let error as RemoteError {
            throw authenticationError(for: error)
        }
    }

    /// Registers a new user in the Simperium Backend.
    ///
    /// - Note: Errors are mapped into SPAuthError Instances
    ///
    /// - Parameters:
    ///     - username: Simperium Username
    ///     - onCompletion: Closure to be executed on completion
    ///
    func signupWithCredentials(username: String, onCompletion: @escaping (SPAuthError?) -> Void) {
        SignupRemote().signup(with: username) { (result) in
            switch result {
            case .success:
                onCompletion(nil)
            case .failure(let error):
                onCompletion(self.authenticationError(for: error))
            }
        }
    }

    private func authenticationError(for remoteError: RemoteError) -> SPAuthError {
        switch remoteError {
        case .network:
            return .network
        case .tooManyAttempts:
            return .tooManyAttempts
        case .requestError(let statusCode, let error):
            return SPAuthError(signupErrorCode: statusCode, response: error?.localizedDescription, error: error)
        }
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
