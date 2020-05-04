import Foundation


// MARK: - AuthenticationValidator
//
struct AuthenticationValidator {

    /// Indicates if we should perform an enhanced validation (Nü Hardened Rules), or just check password length
    ///
    let hardenedValidation: Bool

    /// Defines the minimum allowed password length
    ///
    let minimumPasswordLength: UInt


    /// Returns the Validation Result for a given Username
    ///
    func performUsernameValidation(username: String) -> Result {
        let predicate = NSPredicate.predicateForEmailValidation()
        return predicate.evaluate(with: username) ? .success : .emailInvalid
    }

    /// Returns the Validation Result for a given Password (with its associated Username)
    ///
    func performPasswordValidation(password: String, username: String) -> Result {
        guard password.count >= minimumPasswordLength else {
            return .passwordTooShort(length: minimumPasswordLength)
        }

        guard hardenedValidation else {
            return .success
        }

        guard password != username else {
            return .passwordMatchesUsername
        }

        guard !password.contains(String.newline), !password.contains(String.tab) else {
            return .passwordContainsInvalidCharacter
        }

        return .success
    }
}


// MARK: - Validation Results
//
extension AuthenticationValidator {
    enum Result {
        case success
        case emailInvalid
        case passwordMatchesUsername
        case passwordTooShort(length: UInt)
        case passwordContainsInvalidCharacter
    }
}


// MARK: - Validation Results: String Conversion
//
extension AuthenticationValidator.Result: CustomStringConvertible {
    var description: String {
        switch self {
        case .success:
            return String()

        case .emailInvalid:
            return NSLocalizedString("Your email address is not valid", comment: "Message displayed when email address is invalid")

        case .passwordMatchesUsername:
            return NSLocalizedString("Password cannot match email", comment: "Message displayed when password is invalid (Signup)")

        case .passwordTooShort(let length):
            let localized = NSLocalizedString("Password must contain at least %d characters", comment: "Message displayed when password is too short. Please preserve the Percent D!")
            return String(format: localized, length)

        case .passwordContainsInvalidCharacter:
            return NSLocalizedString("Password must not contain tabs nor newlines", comment: "Message displayed when a password contains a disallowed character")

        }
    }
}


// MARK: - Validation Results: Equality
//
func ==(lhs: AuthenticationValidator.Result, rhs: AuthenticationValidator.Result) -> Bool {
    switch (lhs, rhs) {
    case (.success, .success):
        return true

    case (.emailInvalid, .emailInvalid):
        return true

    case (.passwordMatchesUsername, .passwordMatchesUsername):
        return true

    case (.passwordTooShort, .passwordTooShort):
        return true

    case (.passwordContainsInvalidCharacter, .passwordContainsInvalidCharacter):
        return true

    default:
        return false
    }
}

func !=(lhs: AuthenticationValidator.Result, rhs: AuthenticationValidator.Result) -> Bool {
    return !(lhs == rhs)
}
