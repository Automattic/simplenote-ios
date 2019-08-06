import Foundation
import UIKit
import SafariServices


// MARK: - SPAuthViewController
//
class SPAuthViewController: UIViewController {

    /// # Email: Input Field
    ///
    @IBOutlet private var emailInputView: SPTextInputView! {
        didSet {
            emailInputView.keyboardType = .emailAddress
            emailInputView.placeholder = AuthenticationStrings.emailPlaceholder
            emailInputView.returnKeyType = .next
            emailInputView.rightView = onePasswordButton
            emailInputView.rightViewInsets = AuthenticationConstants.onePasswordInsets
            emailInputView.rightViewMode = .always
            emailInputView.textColor = .color(name: .simplenoteAlmostBlack)
            emailInputView.delegate = self
        }
    }

    /// # Email: Warning Label
    ///
    @IBOutlet private var emailWarningLabel: SPLabel! {
        didSet {
            emailWarningLabel.textInsets = AuthenticationConstants.warningInsets
            emailWarningLabel.isHidden = true
        }
    }

    /// # Password: Input Field
    ///
    @IBOutlet private var passwordInputView: SPTextInputView! {
        didSet {
            passwordInputView.isSecureTextEntry = true
            passwordInputView.placeholder = AuthenticationStrings.passwordPlaceholder
            passwordInputView.returnKeyType = .done
            passwordInputView.rightView = revealPasswordButton
            passwordInputView.rightViewMode = .always
            passwordInputView.rightViewInsets = AuthenticationConstants.onePasswordInsets
            passwordInputView.textColor = .color(name: .simplenoteAlmostBlack)
            passwordInputView.delegate = self
        }
    }

    /// # Password: Warning Label
    ///
    @IBOutlet private var passwordWarningLabel: SPLabel! {
        didSet {
            passwordWarningLabel.textInsets = AuthenticationConstants.warningInsets
            passwordWarningLabel.isHidden = true
        }
    }

    /// # Primary Action: LogIn / SignUp
    ///
    @IBOutlet private var primaryActionButton: SPSquaredButton! {
        didSet {
            primaryActionButton.setTitle(mode.primaryActionText, for: .normal)
            primaryActionButton.setTitleColor(.white, for: .normal)
            primaryActionButton.addTarget(self, action: mode.primaryActionSelector, for: .touchUpInside)
        }
    }

    /// # Primary Action Spinner!
    ///
    @IBOutlet private var primaryActionSpinner: UIActivityIndicatorView! {
        didSet {
            primaryActionSpinner.style = .white
        }
    }

    /// # Forgot Password Action
    ///
    @IBOutlet private var secondaryActionButton: UIButton! {
        didSet {
            if let title = mode.secondaryActionText {
                secondaryActionButton.setTitle(title, for: .normal)
                secondaryActionButton.setTitleColor(.color(name: .simplenoteLightNavy), for: .normal)
            }

            if let attributedTitle = mode.secondaryActionAttributedText {
                secondaryActionButton.setAttributedTitle(attributedTitle, for: .normal)
            }

            secondaryActionButton.titleLabel?.textAlignment = .center
            secondaryActionButton.titleLabel?.numberOfLines = 0
            secondaryActionButton.addTarget(self, action: mode.secondaryActionSelector, for: .touchUpInside)
        }
    }

    /// # 1Password Button
    ///
    private lazy var onePasswordButton: UIButton = {
        let button = UIButton(type: .custom)
        button.tintColor = .color(name: .simplenoteSlateGrey)
        button.setImage(.image(name: .onePasswordImage), for: .normal)
        button.addTarget(self, action: mode.onePasswordSelector, for: .touchUpInside)
        button.sizeToFit()
        return button
    }()

    /// # Reveal Password Button
    ///
    private lazy var revealPasswordButton: UIButton = {
        let button = UIButton(type: .custom)
        button.tintColor = .color(name: .simplenoteSlateGrey)
        button.addTarget(self, action: #selector(revealPasswordWasPressed), for: [.touchDown])
        button.addTarget(self, action: #selector(revealPasswordWasReleased), for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
        button.setImage(.image(name: .visibilityOffImage), for: .normal)
        button.setImage(.image(name: .visibilityOnImage), for: .highlighted)
        button.sizeToFit()

        return button
    }()

    /// # Simperium's Authenticator Instance
    ///
    private let controller: SPAuthHandler

    /// # Simperium's Validator
    ///
    private let validator = SPAuthenticationValidator()

    /// # Indicates if we've got a valid Username. Doesn't display any validation warnings onscreen
    ///
    private var isUsernameValid: Bool {
        return validator.validateUsername(email)
    }

    /// # Indicates if we've got a valid Password. Doesn't display any validation warnings onscreen
    ///
    private var isPasswordValid: Bool {
        return validator.validatePasswordSecurity(password)
    }

    /// # Indicates if we've got valid Credentials. Doesn't display any validation warnings onscreen
    ///
    private var isInputValid: Bool {
        return isUsernameValid && isPasswordValid
    }

    /// # Returns the EmailInputView's Text: When empty this getter returns an empty string, instead of nil
    ///
    private var email: String {
        return emailInputView.text ?? String()
    }

    /// # Returns the PasswordInputView's Text: When empty this getter returns an empty string, instead of nil
    ///
    private var password: String {
        return passwordInputView.text ?? String()
    }

    /// # Authentication Mode: Signup or Login
    ///
    let mode: AuthenticationMode


    /// NSCodable Required Initializer
    ///
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    /// Deinitializer!
    ///
    deinit {
        stopListeningToNotifications()
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
        startListeningToNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailInputView.becomeFirstResponder()
        refreshOnePasswordAvailability()
        ensureStylesMatchValidationState()
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

    func startListeningToNotifications() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(refreshOnePasswordAvailability), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    func stopListeningToNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    func ensureStylesMatchValidationState() {
        let name: UIColorName = isInputValid ? .simplenoteLightNavy : .simplenotePalePurple
        primaryActionButton.backgroundColor = .color(name: name)
    }

    @objc func refreshOnePasswordAvailability() {
        emailInputView.rightViewMode = controller.isOnePasswordAvailable ? .always : .never
    }
}


// MARK: - Actions
//
private extension SPAuthViewController {

    @IBAction func performLogIn() {
        lockdownInterface()

        controller.loginWithCredentials(username: email, password: password) { error in
            if let error = error {
                self.presentError(error: error)
            } else {
                SPTracker.trackUserSignedIn()
            }

            self.unlockInterface()
        }
    }

    @IBAction func performSignUp() {
        lockdownInterface()

        controller.signupWithCredentials(username: email, password: password) { error in
            if let error = error {
                self.presentError(error: error)
            } else {
                SPTracker.trackUserAccountCreated()
            }

            self.unlockInterface()
        }
    }

    @IBAction func performOnePasswordLogIn() {
        controller.findOnePasswordLogin(presenter: self) { (username, password, error) in
            guard let username = username, let password = password else {
                if error == .onePasswordError {
                    SPTracker.trackOnePasswordLoginFailure()
                }

                return
            }

            self.emailInputView.text = username
            self.passwordInputView.text = password

            self.primaryActionButton.sendActions(for: .touchUpInside)
            SPTracker.trackOnePasswordLoginSuccess()
        }
    }

    @IBAction func performOnePasswordSignUp() {
        controller.saveLoginToOnePassword(presenter: self, username: email, password: password) { (username, password, error) in
            guard let username = username, let password = password else {
                if error == .onePasswordError {
                    SPTracker.trackOnePasswordSignupFailure()
                }

                return
            }

            self.emailInputView.text = username
            self.passwordInputView.text = password

            self.primaryActionButton.sendActions(for: .touchUpInside)
            SPTracker.trackOnePasswordSignupSuccess()
        }
    }

    @IBAction func presentPasswordReset() {
        controller.presentPasswordReset(from: self, username: email)
    }

    @IBAction func presentTermsOfService() {
        guard let targetURL = URL(string: kSimperiumTermsOfServiceURL) else {
            return
        }

        let safariViewController = SFSafariViewController(url: targetURL)
        safariViewController.modalPresentationStyle = .overFullScreen
        present(safariViewController, animated: true, completion: nil)
    }

    func lockdownInterface() {
        view.endEditing(true)
        view.isUserInteractionEnabled = false
        primaryActionSpinner.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    func unlockInterface() {
        view.isUserInteractionEnabled = true
        primaryActionSpinner.stopAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}


// MARK: - Error Handling
//
private extension SPAuthViewController {

    func presentError(error: SPAuthError) {
        guard let description = error.description else {
            return
        }

        let alertController = UIAlertController(title: nil, message: description, preferredStyle: .alert)
        alertController.addDefaultActionWithTitle(AuthenticationStrings.acceptActionText)
        present(alertController, animated: true, completion: nil)
    }

    func displayInvalidEmailWarning() {
        emailWarningLabel.text = AuthenticationStrings.usernameInvalid
        emailWarningLabel.animateVisibility(isHidden: false)
    }

    func displayInvalidPasswordWarning() {
        passwordWarningLabel.text = AuthenticationStrings.passwordInvalid
        passwordWarningLabel.animateVisibility(isHidden: false)
    }

    func ensureValidationWarningsAreDismissed() {
        if isUsernameValid {
            emailWarningLabel.animateVisibility(isHidden: true)
        }

        if isPasswordValid {
            passwordWarningLabel.animateVisibility(isHidden: true)
        }
    }
}


// MARK: - UITextFieldDelegate Conformance
//
extension SPAuthViewController: SPTextInputViewDelegate {

    func textInputDidChange(_ textInput: SPTextInputView) {
        ensureStylesMatchValidationState()
        ensureValidationWarningsAreDismissed()
    }

    func textInputShouldReturn(_ textInput: SPTextInputView) -> Bool {
        switch textInput {
        case emailInputView:
            if isUsernameValid {
                passwordInputView.becomeFirstResponder()
            } else {
                displayInvalidEmailWarning()
            }

            return false

        case passwordInputView:
            if isPasswordValid {
                primaryActionButton.sendActions(for: .touchUpInside)
            } else {
                displayInvalidPasswordWarning()
            }

        default:
            // NO-OP
            break
        }

        return true
    }
}


// MARK: - AuthenticationMode: Signup / Login
//
struct AuthenticationMode {
    let title: String
    let onePasswordSelector: Selector
    let primaryActionSelector: Selector
    let primaryActionText: String
    let secondaryActionSelector: Selector
    let secondaryActionText: String?
    let secondaryActionAttributedText: NSAttributedString?
}


// MARK: - Default Operation Modes
//
extension AuthenticationMode {

    /// Login Operation Mode: Contains all of the strings + delegate wirings, so that the AuthUI handles authentication scenarios.
    ///
    static var login: AuthenticationMode {
        return .init(title:                         AuthenticationStrings.loginTitle,
                     onePasswordSelector:           #selector(SPAuthViewController.performOnePasswordLogIn),
                     primaryActionSelector:         #selector(SPAuthViewController.performLogIn),
                     primaryActionText:             AuthenticationStrings.loginPrimaryAction,
                     secondaryActionSelector:       #selector(SPAuthViewController.presentPasswordReset),
                     secondaryActionText:           AuthenticationStrings.loginSecondaryAction,
                     secondaryActionAttributedText: nil)
    }

    /// Signup Operation Mode: Contains all of the strings + delegate wirings, so that the AuthUI handles user account creation scenarios.
    ///
    static var signup: AuthenticationMode {
        return .init(title:                         AuthenticationStrings.signupTitle,
                     onePasswordSelector:           #selector(SPAuthViewController.performOnePasswordSignUp),
                     primaryActionSelector:         #selector(SPAuthViewController.performSignUp),
                     primaryActionText:             AuthenticationStrings.signupPrimaryAction,
                     secondaryActionSelector:       #selector(SPAuthViewController.presentTermsOfService),
                     secondaryActionText:           nil,
                     secondaryActionAttributedText: AuthenticationStrings.signupSecondaryAttributedAction)
    }
}


// MARK: - Authentication Strings
//
private enum AuthenticationStrings {
    static let loginTitle                   = NSLocalizedString("Log In", comment: "LogIn Interface Title")
    static let loginPrimaryAction           = NSLocalizedString("Log In", comment: "LogIn Action")
    static let loginSecondaryAction         = NSLocalizedString("Forgotten password?", comment: "Password Reset Action")
    static let signupTitle                  = NSLocalizedString("Sign Up", comment: "SignUp Interface Title")
    static let signupPrimaryAction          = NSLocalizedString("Sign Up", comment: "SignUp Action")
    static let signupSecondaryActionPrefix  = NSLocalizedString("By creating an account you agree to our", comment: "Terms of Service Legend *PREFIX*: printed in dark color")
    static let signupSecondaryActionSuffix  = NSLocalizedString("Terms and Conditions", comment: "Terms of Service Legend *SUFFIX*: Concatenated with a space, after the PREFIX, and printed in blue")
    static let emailPlaceholder             = NSLocalizedString("Email", comment: "Email TextField Placeholder")
    static let passwordPlaceholder          = NSLocalizedString("Password", comment: "Password TextField Placeholder")
    static let acceptActionText             = NSLocalizedString("Accept", comment: "Accept error message")
    static let usernameInvalid              = NSLocalizedString("Your email address is not valid", comment: "Message displayed when email address is invalid")
    static let passwordInvalid              = NSLocalizedString("Password must contain at least 4 characters", comment: "Message displayed when password is invalid")
}


// MARK: - Strings >> Authenticated Strings Convenience Properties
//
private extension AuthenticationStrings {

    /// Returns a properly formatted Secondary Action String for Signup
    ///
    static var signupSecondaryAttributedAction: NSAttributedString {
        let output = NSMutableAttributedString(string: String(), attributes: [
            .font: UIFont.preferredFont(forTextStyle: .subheadline)
        ])

        output.append(string: signupSecondaryActionPrefix, foregroundColor: .color(name: .simplenoteGunmetal))
        output.append(string: " ")
        output.append(string: signupSecondaryActionSuffix, foregroundColor: .color(name: .simplenoteLightNavy))

        return output
    }
}


// MARK: - Authentication Constants
//
private enum AuthenticationConstants {
    static let onePasswordInsets    = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
    static let warningInsets        = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
}
