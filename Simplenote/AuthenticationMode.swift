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


// MARK: - Authentication Elements
//
struct AuthenticationInputElements: OptionSet {
    let rawValue: UInt
    
    static let username         = AuthenticationInputElements(rawValue: 1 << 0)
    static let password         = AuthenticationInputElements(rawValue: 1 << 1)
    static let code             = AuthenticationInputElements(rawValue: 1 << 2)
    static let actionSeparator  = AuthenticationInputElements(rawValue: 1 << 3)
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
        
    init(name: AuthenticationActionName, selector: Selector, text: String?, attributedText: NSAttributedString? = nil) {
        self.name = name
        self.selector = selector
        self.text = text
        self.attributedText = attributedText
    }
}


// MARK: - AuthenticationMode: Signup / Login
//
struct AuthenticationMode {
    let title: String
    let inputElements: AuthenticationInputElements
    let validationStyle: AuthenticationValidator.Style
    let actions: [AuthenticationActionDescriptor]
}

// MARK: - Default Operation Modes
//
extension AuthenticationMode {

    /// Login with Password
    ///
    static var loginWithPassword: AuthenticationMode {
        return .init(title: NSLocalizedString("Log In with Password", comment: "LogIn Interface Title"),
                     inputElements: [.password],
                     validationStyle: .legacy,
                     actions: [
                        AuthenticationActionDescriptor(name: .primary,
                                                       selector: #selector(SPAuthViewController.performLogInWithPassword),
                                                       text: NSLocalizedString("Log In", comment: "LogIn Action")),
                        AuthenticationActionDescriptor(name: .secondary,
                                                       selector: #selector(SPAuthViewController.presentPasswordReset),
                                                       text: NSLocalizedString("Forgot your password?", comment: "Password Reset Action"))
                     ])
    }

    /// Requests a Login Code
    ///
    static var requestLoginCode: AuthenticationMode {
        return .init(title: NSLocalizedString("Log In", comment: "LogIn Interface Title"),
                     inputElements: [.username, .actionSeparator],
                     validationStyle: .legacy,
                     actions: [
                        AuthenticationActionDescriptor(name: .primary,
                                                       selector: #selector(SPAuthViewController.requestLogInCode),
                                                       text: NSLocalizedString("Log in with email", comment: "Sends the User an email with an Authentication Code")),
                        AuthenticationActionDescriptor(name: .tertiary,
                                                       selector: #selector(SPAuthViewController.performLogInWithWPCOM),
                                                       text: NSLocalizedString("Log in with WordPress.com", comment: "Password fallback Action"))
                     ])
    }
    
    /// Login with Code: Submit Code + Authenticate the user
    ///
    static var loginWithCode: AuthenticationMode {
        return .init(title: NSLocalizedString("Enter Code", comment: "LogIn Interface Title"),
                     inputElements: [.code, .actionSeparator],
                     validationStyle: .legacy,
                     actions: [
                        AuthenticationActionDescriptor(name: .primary,
                                                       selector: #selector(SPAuthViewController.performLogInWithCode),
                                                       text: NSLocalizedString("Log In", comment: "LogIn Interface Title")),
                        AuthenticationActionDescriptor(name: .quaternary,
                                                       selector: #selector(SPAuthViewController.presentPasswordInterface),
                                                       text: NSLocalizedString("Enter password", comment: "Enter Password fallback Action")),
                     ])
    }

    /// Signup: Contains all of the strings + delegate wirings, so that the AuthUI handles user account creation scenarios.
    ///
    static var signup: AuthenticationMode {
        return .init(title: NSLocalizedString("Sign Up", comment: "SignUp Interface Title"),
                     inputElements: [.username],
                     validationStyle: .strong,
                     actions: [
                        AuthenticationActionDescriptor(name: .primary,
                                                       selector: #selector(SPAuthViewController.performSignUp),
                                                       text: NSLocalizedString("Sign Up", comment: "SignUp Action")),
                        AuthenticationActionDescriptor(name: .secondary,
                                                       selector: #selector(SPAuthViewController.presentTermsOfService),
                                                       text: nil,
                                                       attributedText: SignupStrings.termsOfService)
                     ])
    }
}


// MARK: - Mode: .signup
//
private enum SignupStrings {

    /// Returns a formatted Secondary Action String for Signup
    ///
    static var termsOfService: NSAttributedString {
        let output = NSMutableAttributedString(string: String(), attributes: [
            .font: UIFont.preferredFont(forTextStyle: .subheadline)
        ])

        let prefix = NSLocalizedString("By creating an account you agree to our", comment: "Terms of Service Legend *PREFIX*: printed in dark color")
        let suffix = NSLocalizedString("Terms and Conditions", comment: "Terms of Service Legend *SUFFIX*: Concatenated with a space, after the PREFIX, and printed in blue")

        output.append(string: prefix, foregroundColor: .simplenoteGray60Color)
        output.append(string: " ")
        output.append(string: suffix, foregroundColor: .simplenoteBlue60Color)

        return output
    }
}