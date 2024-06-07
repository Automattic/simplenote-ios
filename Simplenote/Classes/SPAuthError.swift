import Foundation

// MARK: - SPAuthError
//
enum SPAuthError: Error {
    case loginBadCredentials
    case signupBadCredentials
    case signupUserAlreadyExists
    case network
    case compromisedPassword
    case unverifiedEmail
    case tooManyAttempts
    case unableToDecode
    case unknown(statusCode: Int, response: String?, error: Error?)
}

// MARK: - SPAuthError Convenience Initializers
//
extension SPAuthError {

    /// Returns the SPAuthError matching a given Simperium Login Error Code
    ///
    init(loginErrorCode: Int, response: String?, error: Error?) {
        switch loginErrorCode {
        case 401 where response == Constants.compromisedPassword:
            self = .compromisedPassword
        case 401:
            self = .loginBadCredentials
        case 403 where response == Constants.requiresVerification:
            self = .unverifiedEmail
        case 429:
            self = .tooManyAttempts
        default:
            self = .unknown(statusCode: loginErrorCode, response: response, error: error)
        }
    }

    /// Returns the SPAuthError matching a given Simperium Signup Error Code
    ///
    init(signupErrorCode: Int, response: String?, error: Error?) {
        switch signupErrorCode {
        case 401:
            self = .signupBadCredentials
        case 409:
            self = .signupUserAlreadyExists
        case 429:
            self = .tooManyAttempts
        default:
            self = .unknown(statusCode: signupErrorCode, response: response, error: error)
        }
    }
}

// MARK: - SPAuthError Public Methods
//
extension SPAuthError {

    /// Returns the Error Title, for Alert purposes
    ///
    var title: String {
        switch self {
        case .signupUserAlreadyExists:
            return NSLocalizedString("Email in use", comment: "Email Taken Alert Title")
        case .compromisedPassword:
            return NSLocalizedString("Compromised Password", comment: "Compromised password alert title")
        case .unverifiedEmail:
            return NSLocalizedString("Account Verification Required", comment: "Email verification required alert title")
        case .tooManyAttempts:
            return NSLocalizedString("Too Many Login Attempts", comment: "Title for too many login attempts error")
        default:
            return NSLocalizedString("Sorry!", comment: "Authentication Error Alert Title")
        }
    }

    /// Returns the Error Message, for Alert purposes
    ///
    var message: String {
        switch self {
        case .loginBadCredentials:
            return NSLocalizedString("Could not login with the provided email address and password.", comment: "Message displayed when login fails")
        case .signupBadCredentials:
            return NSLocalizedString("Could not create an account with the provided email address and password.", comment: "Error for bad email or password")
        case .signupUserAlreadyExists:
            return NSLocalizedString("The email you've entered is already associated with a Simplenote account.", comment: "Error when address is in use")
        case .network:
            return NSLocalizedString("The network could not be reached.", comment: "Error when the network is inaccessible")
        case .compromisedPassword:
            return NSLocalizedString("This password has appeared in a data breach, which puts your account at high risk of compromise. To protect your data, you'll need to update your password before being able to log in again.", comment: "error for compromised password")
        case .unverifiedEmail:
            return NSLocalizedString("You must verify your email before being able to login.", comment: "Error for un verified email")
        case .tooManyAttempts:
            return NSLocalizedString("Too many login attempts. Try again later.", comment: "Error message for too many login attempts")
        default:
            return NSLocalizedString("We're having problems. Please try again soon.", comment: "Generic error")
        }
    }
}

private struct Constants {
    static let compromisedPassword = "compromised password"
    static let requiresVerification = "verification required"
}
