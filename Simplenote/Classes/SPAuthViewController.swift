import Foundation
import UIKit
import SafariServices


// MARK: - SPAuthViewController
//
class SPAuthViewController: UIViewController {

    /// Email Input
    ///
    @IBOutlet private var emailInputView: SPTextInputView! {
        didSet {
            emailInputView.keyboardType = .emailAddress
            emailInputView.placeholder = Constants.emailPlaceholder
            emailInputView.returnKeyType = .next
            emailInputView.rightView = onePasswordButton
            emailInputView.rightViewInsets = Constants.onePasswordInsets
            emailInputView.rightViewMode = .always
            emailInputView.textColor = .simplenoteAlmostBlack()
        }
    }

    /// Password Input
    ///
    @IBOutlet private var passwordInputView: SPTextInputView! {
        didSet {
            passwordInputView.isSecureTextEntry = true
            passwordInputView.placeholder = Constants.passwordPlaceholder
            passwordInputView.returnKeyType = .done
            passwordInputView.rightView = revealPasswordButton
            passwordInputView.rightViewMode = .always
            passwordInputView.rightViewInsets = Constants.onePasswordInsets
            passwordInputView.textColor = .simplenoteAlmostBlack()
        }
    }

    /// Login Action
    ///
    @IBOutlet private var primaryActionButton: SPSquaredButton! {
        didSet {
            primaryActionButton.setTitle(mode.primaryActionText, for: .normal)
            primaryActionButton.setTitleColor(.white, for: .normal)
            primaryActionButton.addTarget(self, action: mode.primaryActionSelector, for: .touchUpInside)
        }
    }

    /// Forgot Password Action
    ///
    @IBOutlet private var secondaryActionButton: UIButton! {
        didSet {
            secondaryActionButton.setTitle(mode.secondaryActionText, for: .normal)
            secondaryActionButton.setTitleColor(.simplenoteLightNavy(), for: .normal)
            secondaryActionButton.titleLabel?.textAlignment = .center
            secondaryActionButton.titleLabel?.numberOfLines = 0
            secondaryActionButton.addTarget(self, action: mode.secondaryActionSelector, for: .touchUpInside)
        }
    }

    /// 1Password Button
    ///
    private lazy var onePasswordButton: UIButton = {
        let button = UIButton(type: .custom)
        button.tintColor = .simplenoteSlateGrey()
        button.setImage(.onePasswordImage, for: .normal)
        button.addTarget(self, action: mode.onePasswordSelector, for: .touchUpInside)
        button.sizeToFit()
        return button
    }()

    /// Reveal Password Button
    ///
    private lazy var revealPasswordButton: UIButton = {
        let button = UIButton(type: .custom)
        button.tintColor = .simplenoteSlateGrey()
        button.setImage(.visibilityOffImage, for: .normal)
        button.setImage(.visibilityOnImage, for: .highlighted)
        button.addTarget(self, action: #selector(revealPasswordWasPressed), for: [.touchDown])
        button.addTarget(self, action: #selector(revealPasswordWasReleased), for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
        button.sizeToFit()
        return button
    }()

    /// Simperium's Authenticator Instance
    ///
    private let controller: SPAuthHandler

    /// Simperium's Validator
    ///
    private let validator = SPAuthenticationValidator()

    /// Indicates if we've got a valid Email + Password
    ///
    private var isInputValid: Bool {
        return validator.validateUsername(email) && validator.validatePasswordSecurity(password)
    }

    ///
    ///
    private var email: String {
        return emailInputView.text ?? String()
    }

    ///
    ///
    private var password: String {
        return passwordInputView.text ?? String()
    }

    /// Authentication Mode: Signup or Login
    ///
    let mode: AuthenticationMode


    /// NSCodable Required Initializer
    ///
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Designated Initializer
    ///
    init(simperiumAuthenticator: SPAuthenticator, mode: AuthenticationMode = .login) {
        self.controller = SPAuthHandler(simperiumService: simperiumAuthenticator)
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }


    // MARK: - Overridden Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailInputView.becomeFirstResponder()
        ensureOnePasswordIsAvailable()
        ensureButtonStylesMatchInputState()
    }
}


// MARK: - Actions
//
extension SPAuthViewController {

    @IBAction func revealPasswordWasPressed() {
        passwordInputView.isSecureTextEntry = false
    }

    @IBAction func revealPasswordWasReleased() {
        passwordInputView.isSecureTextEntry = true
    }
}


// MARK: - Interface
//
private extension SPAuthViewController {

    func setupNavigationController() {
        title = mode.title
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.applySimplenoteLightStyle()
    }

    func ensureButtonStylesMatchInputState() {
        primaryActionButton.backgroundColor = isInputValid ? .simplenoteLightNavy() : .simplenotePalePurple()
    }
}


// MARK: - Actions
//
private extension SPAuthViewController {

    @IBAction func performLogIn() {
// TODO
        controller.loginWithCredentials(username: email, password: password)
        SPTracker.trackUserSignedIn()
    }

    @IBAction func performSignUp() {
// TODO
        SPTracker.trackUserAccountCreated()
    }

    @IBAction func performOnePasswordLogIn() {
        view.endEditing(true)

        controller.findOnePasswordLogin(presenter: self) { (username, password, error) in
            guard let username = username, let password = password else {
                if error == .onePasswordError {
                    SPTracker.trackOnePasswordLoginFailure()
                }

                return
            }

            self.emailInputView.text = username
            self.passwordInputView.text = password

            self.performLogIn()
            SPTracker.trackOnePasswordLoginSuccess()
        }
    }

    @IBAction func performOnePasswordSignUp() {
// TODO
    }

    @IBAction func presentPasswordReset() {
        let email = emailInputView.text ?? ""
        let resetPasswordPath = kSimperiumForgotPasswordURL + "?email=" + email
        guard let forgotPasswordURL = URL(string: resetPasswordPath) else {
            return
        }

        let safariViewController = SFSafariViewController(url: forgotPasswordURL)
        safariViewController.modalPresentationStyle = .overFullScreen
        present(safariViewController, animated: true, completion: nil)
    }

    @IBAction func presentTermsOfService() {
        guard let targetURL = URL(string: kSimperiumTermsOfServiceURL) else {
            return
        }

        let safariViewController = SFSafariViewController(url: targetURL)
        safariViewController.modalPresentationStyle = .overFullScreen
        present(safariViewController, animated: true, completion: nil)
    }
}


// MARK: - Private
//
private extension SPAuthViewController {

    func ensureOnePasswordIsAvailable() {
        emailInputView.rightViewMode = controller.isOnePasswordAvailable() ? .always : .never
    }
}


//- (IBAction)signInErrorAction:(NSNotification *)notification
//{
//    NSString *errorMessage = NSLocalizedString(@"An error was encountered while signing in.", @"Sign in error message");
//    if (notification.userInfo != nil && notification.userInfo[@"errorString"]) {
//        errorMessage = [notification.userInfo valueForKey:@"errorString"];
//    }
//
//    [self dismissViewControllerAnimated:YES completion:nil];
//    UIAlertController* errorAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Couldn't Sign In", @"Alert dialog title displayed on sign in error")
//                                                                   message:errorMessage
//                                                            preferredStyle:UIAlertControllerStyleAlert];
//
//    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
//                                                          handler:^(UIAlertAction * action) {}];
//
//    [errorAlert addAction:defaultAction];
//    [self presentViewController:errorAlert animated:YES completion:nil];
//}


// MARK: - AuthenticationMode: Signup / Login
//
struct AuthenticationMode {
    let title: String
    let onePasswordSelector: Selector
    let primaryActionSelector: Selector
    let primaryActionText: String
    let secondaryActionSelector: Selector
    let secondaryActionText: String
}


// MARK: - Default Operation Modes
//
extension AuthenticationMode {

    /// Login Operation Mode: Contains all of the strings + delegate wirings, so that the AuthUI handles
    /// authentication scenarios.
    ///
    static var login: AuthenticationMode {
        let title               = NSLocalizedString("Log In", comment: "LogIn Interface Title")
        let onePasswordSelector = #selector(SPAuthViewController.performOnePasswordLogIn)
        let primaryText         = NSLocalizedString("Log In", comment: "LogIn Action")
        let primarySelector     = #selector(SPAuthViewController.performLogIn)
        let secondaryText       = NSLocalizedString("Forgotten password?", comment: "Password Reset Action")
        let secondarySelector   = #selector(SPAuthViewController.presentPasswordReset)

        return AuthenticationMode(title: title,
                                  onePasswordSelector: onePasswordSelector,
                                  primaryActionSelector: primarySelector,
                                  primaryActionText: primaryText,
                                  secondaryActionSelector: secondarySelector,
                                  secondaryActionText: secondaryText)
    }

    /// Signup Operation Mode: Contains all of the strings + delegate wirings, so that the AuthUI handles
    /// user account creation scenarios.
    ///
    static var signup: AuthenticationMode {
        let title               = NSLocalizedString("Sign Up", comment: "SignUp Interface Title")
        let onePasswordSelector = #selector(SPAuthViewController.performOnePasswordSignUp)
        let primaryText         = NSLocalizedString("Sign Up", comment: "SignUp Action")
        let primarySelector     = #selector(SPAuthViewController.performSignUp)
        let secondaryText       = NSLocalizedString("By creating an account you agree to our Terms and Conditions", comment: "Terms of Service Legend")
        let secondarySelector   = #selector(SPAuthViewController.presentTermsOfService)

        return AuthenticationMode(title: title,
                                  onePasswordSelector: onePasswordSelector,
                                  primaryActionSelector: primarySelector,
                                  primaryActionText: primaryText,
                                  secondaryActionSelector: secondarySelector,
                                  secondaryActionText: secondaryText)
    }
}


// MARK: - Constants
//
private struct Constants {
    static let emailPlaceholder     = NSLocalizedString("Email", comment: "Email TextField Placeholder")
    static let passwordPlaceholder  = NSLocalizedString("Password", comment: "Password TextField Placeholder")
    static let onePasswordInsets    = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
}
