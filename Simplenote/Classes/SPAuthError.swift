import Foundation


// MARK: - SPAuthError
//
enum SPAuthError: Error {
    case loginBadCredentials
    case signupBadCredentials
    case signupUserAlreadyExists
    case unknown(responseCode: Int)
}


// MARK: - SPAuthError Convenience Initializers
//
extension SPAuthError {

    /// Returns the SPAuthError matching a given Simperium Login Error Code
    ///
    init(simperiumLoginErrorCode: Int) {
        switch simperiumLoginErrorCode {
        case Constants.badCredentials:
            self = .loginBadCredentials
        default:
            self = .unknown(responseCode: simperiumLoginErrorCode)
        }
    }

    /// Returns the SPAuthError matching a given Simperium Signup Error Code
    ///
    init(simperiumSignupErrorCode: Int) {
        switch simperiumSignupErrorCode {
        case Constants.badCredentials:
            self = .signupBadCredentials
        case Constants.userAlreadyExists:
            self = .signupUserAlreadyExists
        default:
            self = .unknown(responseCode: simperiumSignupErrorCode)
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
        default:
            return NSLocalizedString("Sorry!", comment: "Authentication Error Alert Title")
        }
    }

    /// Returns the Error Message, for Alert purposes
    ///
    var message: String {
        switch self {
        case .loginBadCredentials:
            return NSLocalizedString("Could not login with the provided email address and password.", comment: "Message displayed when login fails");
        case .signupBadCredentials:
            return NSLocalizedString("Could not sign up with the provided email address and password.", comment: "Error for bad email or password")
        case .signupUserAlreadyExists:
            return NSLocalizedString("The email you've entered is already associated with a Simplenote account.", comment: "Error when address is in use")
        case .unknown:
            return NSLocalizedString("We're having problems. Please try again soon.", comment: "Generic error")
        }
    }

    /// Returns the Raw responseCode
    ///
    var responseCode: Int {
        switch self {
        case .loginBadCredentials, .signupBadCredentials:
            return Constants.badCredentials
        case .signupUserAlreadyExists:
            return Constants.userAlreadyExists
        case .unknown(let responseCode):
            return responseCode
        }
    }
}


// MARK: - Constants
//
private struct Constants {
    static let badCredentials = 401
    static let userAlreadyExists = 409
}


// MARK: - Equatable Conformance
//
func ==(lhs: SPAuthError, rhs: SPAuthError) -> Bool {
    switch (lhs, rhs) {
    case (.loginBadCredentials, .loginBadCredentials):
        return true
    case (.signupBadCredentials, .signupBadCredentials):
        return true
    case (.signupUserAlreadyExists, .signupUserAlreadyExists):
        return true
    case (.unknown(let lhsCode), .unknown(let rhsCode)):
        return lhsCode == rhsCode
    default:
        return false
    }
}
