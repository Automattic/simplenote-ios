import Foundation

// MARK: - AuthenticationValidator
//
struct AuthenticationValidator {

    /// Minimum Password Length: Login
    ///
    private let legacyPasswordLength  = UInt(4)

    /// Minimum Password Length: SignUp
    ///
    private let strongPasswordLength = UInt(8)

    /// Returns the Validation Result for a given Username
    ///
    func performUsernameValidation(username: String) -> Result {
        let predicate = NSPredicate.predicateForEmailValidation()
        return predicate.evaluate(with: username) ? .success : .emailInvalid
    }

    /// Returns the Validation Result for a given Password (with its associated Username)
    ///
    func performPasswordValidation(username: String, password: String, style: Style = .strong) -> Result {
        let requiredPasswordLength = minimumPasswordLength(for: style)

        guard password.count >= requiredPasswordLength else {
            return .passwordTooShort(length: requiredPasswordLength)
        }

        guard style == .strong else {
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

    /// Defines the minimum allowed password length
    ///
    private func minimumPasswordLength(for style: Style) -> UInt {
        return (style == .legacy) ? legacyPasswordLength : strongPasswordLength
    }
}

// MARK: - Nested Types
//
extension AuthenticationValidator {

    enum Style {
        case legacy
        case strong
    }

    enum Result: Equatable {
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
            // Not really needed. But for convenience reasons, it's super if this property isn't optional.
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
