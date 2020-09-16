import Foundation
import OnePasswordExtension


// MARK: - SPAuthError
//
enum SPAuthError: Error {
    case onePasswordCancelled
    case onePasswordError
    case loginBadCredentials
    case signupBadCredentials
    case signupUserAlreadyExists
    case unknown(statusCode: Int, response: String?, requestError: Error?)
}


// MARK: - SPAuthError Convenience Initializers
//
extension SPAuthError {

    /// Returns the SPAuthError matching a given OnePasswordError (If possible!)
    ///
    init?(onePasswordError: Error?) {
        guard let error = onePasswordError as NSError? else {
            return nil
        }

        self = error.code == AppExtensionErrorCode.cancelledByUser.rawValue ? .onePasswordError : .onePasswordCancelled
    }

    /// Returns the SPAuthError matching a given Simperium Login Error Code
    ///
    init(loginErrorCode: Int, response: String?, error: Error?) {
        switch loginErrorCode {
        case 401:
            self = .loginBadCredentials
        default:
            self = .unknown(statusCode: loginErrorCode, response: response, requestError: error)
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
        default:
            self = .unknown(statusCode: signupErrorCode, response: response, requestError: error)
        }
    }
}


// MARK: - SPAuthError Public Methods
//
extension SPAuthError {

    /// Returns the Error Title, for Alert purposes
    ///
    var title: String? {
        switch self {
        case .signupUserAlreadyExists:
            return NSLocalizedString("Email in use", comment: "Email Taken Alert Title")
        default:
            return NSLocalizedString("Sorry!", comment: "Authentication Error Alert Title")
        }
    }

    /// Returns the Error Message, for Alert purposes
    ///
    var message: String? {
        switch self {
        case .loginBadCredentials:
            return NSLocalizedString("Could not login with the provided email address and password.", comment: "Message displayed when login fails");
        case .signupBadCredentials:
            return NSLocalizedString("Could not create an account with the provided email address and password.", comment: "Error for bad email or password")
        case .signupUserAlreadyExists:
            return NSLocalizedString("The email you've entered is already associated with a Simplenote account.", comment: "Error when address is in use")
        case .unknown:
            return NSLocalizedString("We're having problems. Please try again soon.", comment: "Generic error")
        default:
            return nil
        }
    }

    /// Indicates if the Error is User Facing, or should be kept internally
    ///
    var shouldBePresentedOnscreen: Bool {
        return message != nil
    }
}
