import Foundation
import UIKit
import SafariServices


// MARK: - SPAuthViewController
//
class SPAuthViewController: UIViewController {

    /// # Links to the StackView and the container view
    ///
    @IBOutlet private var stackViewTopConstraint: NSLayoutConstraint!

    /// # StackView: Contains the entire UI
    ///
    @IBOutlet private var stackView: UIStackView!

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
            emailInputView.textColor = .simplenoteGray80Color
            emailInputView.delegate = self
            emailInputView.textContentType = .username
        }
    }

    /// # Email: Warning Label
    ///
    @IBOutlet private var emailWarningLabel: SPLabel! {
        didSet {
            emailWarningLabel.textInsets = AuthenticationConstants.warningInsets
            emailWarningLabel.textColor = .simplenoteRed60Color
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
            passwordInputView.textColor = .simplenoteGray80Color
            passwordInputView.delegate = self
            passwordInputView.textContentType = .password
        }
    }

    /// # Password: Warning Label
    ///
    @IBOutlet private var passwordWarningLabel: SPLabel! {
        didSet {
            passwordWarningLabel.textInsets = AuthenticationConstants.warningInsets
            passwordWarningLabel.textColor = .simplenoteRed60Color
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
                secondaryActionButton.setTitleColor(.simplenoteBlue60Color, for: .normal)
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
        button.tintColor = .simplenoteGray50Color
        button.setImage(.image(name: .onePassword), for: .normal)
        button.addTarget(self, action: mode.onePasswordSelector, for: .touchUpInside)
        button.sizeToFit()
        return button
    }()

    /// # Reveal Password Button
    ///
    private lazy var revealPasswordButton: UIButton = {
        let selected = UIImage.image(name: .visibilityOn)
        let button = UIButton(type: .custom)
        button.tintColor = .simplenoteGray50Color
        button.addTarget(self, action: #selector(revealPasswordWasPressed), for: [.touchDown])
        button.setImage(.image(name: .visibilityOff), for: .normal)
        button.setImage(selected, for: .highlighted)
        button.setImage(selected, for: .selected)
        button.sizeToFit()

        return button
    }()

    /// # Simperium's Authenticator Instance
    ///
    private let controller: SPAuthHandler

    /// # Simperium's Validator
    ///
    private lazy var validator = AuthenticationValidator()

    /// # Indicates if we've got valid Credentials. Doesn't display any validation warnings onscreen
    ///
    private var isInputValid: Bool {
        return performUsernameValidation() == .success && performPasswordValidation() == .success
    }

    /// # Returns the EmailInputView's Text: When empty this getter returns an empty string, instead of nil
    ///
    private var email: String {
        get {
            return emailInputView.text ?? String()
        }
        set {
            emailInputView.text = newValue
        }
    }

    /// # Returns the PasswordInputView's Text: When empty this getter returns an empty string, instead of nil
    ///
    private var password: String {
        get {
            return passwordInputView.text ?? String()
        }
        set {
            passwordInputView.text = newValue
        }
    }

    /// Indicates if we must nuke the Password Field's contents whenever the App becomes active
    ///
    private var mustResetPasswordField = false

    /// # Authentication Mode: Signup or Login
    ///
    let mode: AuthenticationMode



    /// NSCodable Required Initializer
    ///
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    /// Designated Initializer
    ///
    init(controller: SPAuthHandler, mode: AuthenticationMode = .login) {
        self.controller = controller
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
        refreshOnePasswordAvailability()
        ensureStylesMatchValidationState()
        performPrimaryActionIfPossible()
        ensureNavigationBarIsVisible()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Note: running becomeFirstResponder in `viewWillAppear` has the weird side effect of breaking caret
        // repositioning in the Text Field. Seriously.
        // Ref. https://github.com/Automattic/simplenote-ios/issues/453
        self.emailInputView.becomeFirstResponder()
    }
}


// MARK: - Actions
//
extension SPAuthViewController {

    @IBAction func revealPasswordWasPressed() {
        let isPasswordVisible = !revealPasswordButton.isSelected
        revealPasswordButton.isSelected = isPasswordVisible
        passwordInputView.isSecureTextEntry = !isPasswordVisible
    }
}


// MARK: - Interface
//
private extension SPAuthViewController {

    func setupNavigationController() {
        title = mode.title
        navigationController?.navigationBar.applyLightStyle()
    }

    func startListeningToNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    func ensureNavigationBarIsVisible() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    func ensureStylesMatchValidationState() {
        primaryActionButton.backgroundColor = isInputValid ? .simplenoteBlue50Color : .simplenoteGray20Color
    }

    @objc
    func applicationDidBecomeActive() {
        refreshOnePasswordAvailability()
        ensurePasswordFieldIsReset()
    }

    func refreshOnePasswordAvailability() {
        emailInputView.rightViewMode = controller.isOnePasswordAvailable ? .always : .never
    }

    func ensurePasswordFieldIsReset() {
        guard mustResetPasswordField else {
            return
        }

        passwordInputView.text = nil
        passwordInputView.becomeFirstResponder()
    }

    private func lockdownInterface() {
        view.endEditing(true)
        view.isUserInteractionEnabled = false
        primaryActionSpinner.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    private func unlockInterface() {
        view.isUserInteractionEnabled = true
        primaryActionSpinner.stopAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}


// MARK: - Actions
//
private extension SPAuthViewController {

    /// Whenever the input is Valid, we'll perform the Primary Action
    ///
    func performPrimaryActionIfPossible() {
        guard isInputValid else {
            return
        }

        perform(mode.primaryActionSelector)
    }

    @IBAction func performLogIn() {
        guard ensureWarningsAreOnScreenWhenNeeded() else {
            return
        }

        if mustUpgradePasswordStrength() {
            performCredentialsValidation()
            return
        }

        performSimperiumAuthentication()
    }

    @IBAction func performSignUp() {
        guard ensureWarningsAreOnScreenWhenNeeded() else {
            return
        }

        lockdownInterface()

        controller.signupWithCredentials(username: email, password: password) { error in
            if let error = error {
                self.handleError(error: error)
            } else {
                SPTracker.trackUserAccountCreated()
            }

            self.unlockInterface()
        }
    }

    @IBAction func performOnePasswordLogIn(sender: Any) {
        controller.findOnePasswordLogin(presenter: self, sender: sender) { (username, password, error) in
            guard let username = username, let password = password else {
                if error == .onePasswordError {
                    SPTracker.trackOnePasswordLoginFailure()
                }

                return
            }

            self.email = username
            self.password = password

            self.performLogIn()
            SPTracker.trackOnePasswordLoginSuccess()
        }
    }

    @IBAction func performOnePasswordSignUp(sender: Any) {
        controller.saveLoginToOnePassword(presenter: self, sender: sender, username: email, password: password) { (username, password, error) in
            guard let username = username, let password = password else {
                if error == .onePasswordError {
                    SPTracker.trackOnePasswordSignupFailure()
                }

                return
            }

            self.email = username
            self.password = password

            self.performSignUp()
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
}


// MARK: - Simperium Services
//
private extension SPAuthViewController {

    func performCredentialsValidation() {
        lockdownInterface()

        controller.validateWithCredentials(username: email, password: password) { error in
            if let error = error {
                self.handleError(error: error)
            } else {
                self.presentPasswordResetRequiredAlert(email: self.email)
            }

            self.unlockInterface()
        }
    }

    func performSimperiumAuthentication() {
        lockdownInterface()

        controller.loginWithCredentials(username: email, password: password) { error in
            if let error = error {
                self.handleError(error: error)
            } else {
                SPTracker.trackUserSignedIn()
            }

            self.unlockInterface()
        }
    }
}


// MARK: - Password Reset Flow
//
private extension SPAuthViewController {

    func presentPasswordResetRequiredAlert(email: String) {
        guard let resetURL = URL(string: SimplenoteConstants.resetPasswordURL + email) else {
            fatalError()
        }

        let alertController = UIAlertController(title: PasswordInsecureString.title, message: PasswordInsecureString.message, preferredStyle: .alert)
        alertController.addCancelActionWithTitle(PasswordInsecureString.cancel)
        alertController.addDefaultActionWithTitle(PasswordInsecureString.reset) { [weak self] _ in
            self?.mustResetPasswordField = true
            UIApplication.shared.open(resetURL, options: [:], completionHandler: nil)
        }

        present(alertController, animated: true, completion: nil)
    }
}


// MARK: - Error Handling
//
private extension SPAuthViewController {

    func handleError(error: SPAuthError) {
        guard error.shouldBePresentedOnscreen else {
            return
        }

        switch error {
        case .signupUserAlreadyExists:
            presentUserAlreadyExistsError(error: error)
        default:
            presentGenericError(error: error)
        }
    }

    func presentUserAlreadyExistsError(error: SPAuthError) {
        let alertController = UIAlertController(title: error.title, message: error.message, preferredStyle: .alert)
        alertController.addCancelActionWithTitle(AuthenticationStrings.cancelActionText)
        alertController.addDefaultActionWithTitle(AuthenticationStrings.loginActionText) { _ in
            self.attemptLoginWithCurrentCredentials()
        }

        present(alertController, animated: true, completion: nil)
    }

    func presentGenericError(error: SPAuthError) {
        let alertController = UIAlertController(title: error.title, message: error.message, preferredStyle: .alert)
        alertController.addDefaultActionWithTitle(AuthenticationStrings.acceptActionText)
        present(alertController, animated: true, completion: nil)
    }

    func attemptLoginWithCurrentCredentials() {
        guard let navigationController = navigationController else {
            fatalError()
        }

        // Prefill the LoginViewController
        let loginViewController = SPAuthViewController(controller: controller, mode: .login)

        loginViewController.loadViewIfNeeded()
        loginViewController.email = email
        loginViewController.password = password

        // Swap the current VC
        var updatedHierarchy = navigationController.viewControllers.filter { ($0 is SPAuthViewController) == false }
        updatedHierarchy.append(loginViewController)
        navigationController.setViewControllers(updatedHierarchy, animated: true)
    }
}


// MARK: - Warning Labels
//
private extension SPAuthViewController {

    func displayEmailValidationWarning(_ string: String) {
        emailWarningLabel.text = string
        refreshEmailInput(inErrorState: true)
    }

    func displayPasswordValidationWarning(_ string: String) {
        passwordWarningLabel.text = string
        refreshPasswordInput(inErrorState: true)
    }

    func dismissEmailValidationWarning() {
        refreshEmailInput(inErrorState: false)
    }

    func dismissPasswordValidationWarning() {
        refreshPasswordInput(inErrorState: false)
    }

    func refreshEmailInput(inErrorState: Bool) {
        emailWarningLabel.animateVisibility(isHidden: !inErrorState)
        emailInputView.inErrorState = inErrorState
    }

    func refreshPasswordInput(inErrorState: Bool) {
        passwordWarningLabel.animateVisibility(isHidden: !inErrorState)
        passwordInputView.inErrorState = inErrorState
    }
}


// MARK: - Validation
//
private extension SPAuthViewController {

    func performUsernameValidation() -> AuthenticationValidator.Result {
        validator.performUsernameValidation(username: email)
    }

    /// When we're in `.login` mode, password requirements are relaxed (since we must allow users with old passwords to sign in).
    /// That's where the `validationStyle` comes in.
    ///
    func performPasswordValidation() -> AuthenticationValidator.Result {
        validator.performPasswordValidation(username: email, password: password, style: mode.validationStyle)
    }

    /// Whenever we're in `.login` mode, and the password is valid in `.legacy` terms (but invalid in `.strong` mode), we must request the
    /// user to reset the password associated to his/her account.
    ///
    func mustUpgradePasswordStrength() -> Bool {
        validator.performPasswordValidation(username: email, password: password, style: .strong) != .success
    }

    func ensureWarningsAreOnScreenWhenNeeded() -> Bool {
        let usernameValidationResult = performUsernameValidation()
        let passwordValidationResult = performPasswordValidation()

        if usernameValidationResult != .success {
            displayEmailValidationWarning(usernameValidationResult.description)
        }

        if passwordValidationResult != .success {
            displayPasswordValidationWarning(passwordValidationResult.description)
        }

        return usernameValidationResult == .success && passwordValidationResult == .success
    }

    func ensureWarningsAreDismissedWhenNeeded() {
        if performUsernameValidation() == .success {
            dismissEmailValidationWarning()
        }

        if performPasswordValidation() == .success {
            dismissPasswordValidationWarning()
        }
    }
}


// MARK: - UITextFieldDelegate Conformance
//
extension SPAuthViewController: SPTextInputViewDelegate {

    func textInputDidChange(_ textInput: SPTextInputView) {
        ensureStylesMatchValidationState()
        ensureWarningsAreDismissedWhenNeeded()
    }

    func textInputShouldReturn(_ textInput: SPTextInputView) -> Bool {
        switch textInput {
        case emailInputView:
            switch performUsernameValidation() {
            case .success:
                passwordInputView.becomeFirstResponder()

            case let error:
                displayEmailValidationWarning(error.description)
            }

        case passwordInputView:
            switch performPasswordValidation() {
            case .success:
                performPrimaryActionIfPossible()

            case let error:
                displayPasswordValidationWarning(error.description)
            }

        default:
            break
        }

        return false
    }
}


// MARK: - AuthenticationMode: Signup / Login
//
struct AuthenticationMode {
    let title: String
    let validationStyle: AuthenticationValidator.Style
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
                     validationStyle:               .legacy,
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
                     validationStyle:               .strong,
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
    static let acceptActionText             = NSLocalizedString("Accept", comment: "Accept Action")
    static let cancelActionText             = NSLocalizedString("Cancel", comment: "Cancel Action")
    static let loginActionText              = NSLocalizedString("Log In", comment: "Log In Action")
}


// MARK: - PasswordInsecure Alert Strings
//
private enum PasswordInsecureString {
    static let cancel = NSLocalizedString("Cancel", comment: "Cancel Action")
    static let reset = NSLocalizedString("Reset", comment: "Reset Action")
    static let title = NSLocalizedString("Reset Required", comment: "Password Reset Required Alert Title")
    static let message = [
        NSLocalizedString("Your password is insecure and must be reset. The password requirements are:", comment: "Password Requirements: Title"),
        String.newline,
        NSLocalizedString("- Password cannot match email", comment: "Password Requirement: Email Match"),
        NSLocalizedString("- Minimum of 8 characters", comment: "Password Requirement: Length"),
        NSLocalizedString("- Neither tabs nor newlines are allowed", comment: "Password Requirement: Special Characters")
    ].joined(separator: .newline)
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

        output.append(string: signupSecondaryActionPrefix, foregroundColor: .simplenoteGray60Color)
        output.append(string: " ")
        output.append(string: signupSecondaryActionSuffix, foregroundColor: .simplenoteBlue60Color)

        return output
    }
}


// MARK: - Authentication Constants
//
private enum AuthenticationConstants {
    static let onePasswordInsets    = NSDirectionalEdgeInsets(top: .zero, leading: 16, bottom: .zero, trailing: 16)
    static let warningInsets        = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
}
