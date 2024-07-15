//
//  AuthenticationMode.swift
//  Simplenote
//
//  Created by Jorge Leandro Perez on 7/15/24.
//  Copyright © 2024 Automattic. All rights reserved.
//

import Foundation


// MARK: - State
//
struct AuthenticationState {
    var username = String()
    var password = String()
    var code = String()
}

struct AuthenticationElements: OptionSet {
    let rawValue: UInt
    
    static let username         = AuthenticationElements(rawValue: 1 << 0)
    static let password         = AuthenticationElements(rawValue: 1 << 1)
    static let code             = AuthenticationElements(rawValue: 1 << 2)
    static let actionSeparator  = AuthenticationElements(rawValue: 1 << 7)
}


// MARK: - Authentication Actions
//
enum AuthenticationActionName {
    case primary
    case secondary
    case tertiary
    case quaternary
}

struct AuthenticationActionDescriptor {
    let name: AuthenticationActionName
    let selector: Selector
    let text: String?
    let attributedText: NSAttributedString?
}


// MARK: - AuthenticationMode: Signup / Login
//
struct AuthenticationMode {
    let title: String
    let validationStyle: AuthenticationValidator.Style
    let visibleElements: AuthenticationElements
    let actions: [AuthenticationActionDescriptor]
}

// MARK: - Default Operation Modes
//
extension AuthenticationMode {

    /// Login Operation Mode: Contains all of the strings + delegate wirings, so that the AuthUI handles authentication scenarios.
    ///
    static var loginWithPassword: AuthenticationMode {
        return .init(title: PasswordStrings.title,
                     validationStyle: .legacy,
                     visibleElements: [.password],
                     actions: [
                        AuthenticationActionDescriptor(name: .primary,
                                                       selector: #selector(SPAuthViewController.performLogInWithPassword),
                                                       text: PasswordStrings.login,
                                                       attributedText: nil),
                        AuthenticationActionDescriptor(name: .secondary,
                                                       selector: #selector(SPAuthViewController.presentPasswordReset),
                                                       text: PasswordStrings.forgotPassword,
                                                       attributedText: nil)
                     ])
    }

    /// Login Operation Mode: Request Login Code
    ///
    static var requestLoginCode: AuthenticationMode {
        return .init(title: RequestCodeStrings.title,
                     validationStyle: .legacy,
                     visibleElements: [.username, .actionSeparator],
                     actions: [
                        AuthenticationActionDescriptor(name: .primary,
                                                       selector: #selector(SPAuthViewController.requestLogInCode),
                                                       text: RequestCodeStrings.loginWithEmail,
                                                       attributedText: nil),
                        AuthenticationActionDescriptor(name: .tertiary,
                                                       selector: #selector(SPAuthViewController.performLogInWithWPCOM),
                                                       text: RequestCodeStrings.loginWithWPCOM,
                                                       attributedText: nil),
                     ])
    }
    
    /// Login Operation Mode: Submit Code + Authenticate the user
    ///
    static var loginWithCode: AuthenticationMode {
        return .init(title: LoginWithCodeStrings.title,
                     validationStyle: .legacy,
                     visibleElements: [.code, .actionSeparator],
                     actions: [
                        AuthenticationActionDescriptor(name: .primary,
                                                       selector: #selector(SPAuthViewController.performLogInWithCode),
                                                       text: LoginWithCodeStrings.login,
                                                       attributedText: nil),
                        AuthenticationActionDescriptor(name: .quaternary,
                                                       selector: #selector(SPAuthViewController.presentPasswordInterface),
                                                       text: LoginWithCodeStrings.enterPassword,
                                                       attributedText: nil),
                     ])
    }

    /// Signup Operation Mode: Contains all of the strings + delegate wirings, so that the AuthUI handles user account creation scenarios.
    ///
    static var signup: AuthenticationMode {
        return .init(title: SignupStrings.title,
                     validationStyle: .strong,
                     visibleElements: [.username],
                     actions: [
                        AuthenticationActionDescriptor(name: .primary,
                                                       selector: #selector(SPAuthViewController.performSignUp),
                                                       text: SignupStrings.signup,
                                                       attributedText: nil),
                        AuthenticationActionDescriptor(name: .secondary,
                                                       selector: #selector(SPAuthViewController.presentTermsOfService),
                                                       text: nil,
                                                       attributedText: SignupStrings.termsOfService)
                     ])
    }
}


// MARK: - Mode: .loginWithPassword
//
private enum PasswordStrings {
    static let title            = NSLocalizedString("Log In with Password", comment: "LogIn Interface Title")
    static let login            = NSLocalizedString("Log In", comment: "LogIn Action")
    static let forgotPassword   = NSLocalizedString("Forgot your password?", comment: "Password Reset Action")
}


// MARK: - Mode: .requestLoginCode
//
private enum RequestCodeStrings {
    static let title            = NSLocalizedString("Log In", comment: "LogIn Interface Title")
    static let loginWithEmail   = NSLocalizedString("Log in with email", comment: "Sends the User an email with an Authentication Code")
    static let loginWithWPCOM   = NSLocalizedString("Log in with WordPress.com", comment: "Password fallback Action")
}


// MARK: - Mode: .code
//
private enum LoginWithCodeStrings {
    static let title            = NSLocalizedString("Enter Code", comment: "LogIn Interface Title")
    static let login            = NSLocalizedString("Log In", comment: "LogIn Interface Title")
    static let enterPassword    = NSLocalizedString("Enter password", comment: "Enter Password fallback Action")
}


// MARK: - Mode: .signup
//
private enum SignupStrings {
    static let title                = NSLocalizedString("Sign Up", comment: "SignUp Interface Title")
    static let signup               = NSLocalizedString("Sign Up", comment: "SignUp Action")
    static let termsOfServicePrefix = NSLocalizedString("By creating an account you agree to our", comment: "Terms of Service Legend *PREFIX*: printed in dark color")
    static let termsOfServiceSuffix = NSLocalizedString("Terms and Conditions", comment: "Terms of Service Legend *SUFFIX*: Concatenated with a space, after the PREFIX, and printed in blue")
}

private extension SignupStrings {

    /// Returns a properly formatted Secondary Action String for Signup
    ///
    static var termsOfService: NSAttributedString {
        let output = NSMutableAttributedString(string: String(), attributes: [
            .font: UIFont.preferredFont(forTextStyle: .subheadline)
        ])

        output.append(string: termsOfServicePrefix, foregroundColor: .simplenoteGray60Color)
        output.append(string: " ")
        output.append(string: termsOfServiceSuffix, foregroundColor: .simplenoteBlue60Color)

        return output
    }
}
