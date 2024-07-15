import Foundation
import UIKit
import SafariServices
import SwiftUI

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
            passwordInputView.rightViewInsets = AuthenticationConstants.accessoryViewInsets
            passwordInputView.passwordRules = UITextInputPasswordRules(descriptor: SimplenoteConstants.passwordRules)
            passwordInputView.returnKeyType = .done
            passwordInputView.rightView = revealPasswordButton
            passwordInputView.rightViewMode = .always
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
    
    /// # Code: Input Field
    ///
    @IBOutlet private var codeInputView: SPTextInputView! {
        didSet {
            codeInputView.placeholder = AuthenticationStrings.codePlaceholder
            codeInputView.passwordRules = UITextInputPasswordRules(descriptor: SimplenoteConstants.passwordRules)
            codeInputView.returnKeyType = .done
            codeInputView.textColor = .simplenoteGray80Color
            codeInputView.delegate = self
            codeInputView.textContentType = .oneTimeCode
        }
    }
    
    /// # Code: Warning Label
    ///
    @IBOutlet private var codeWarningLabel: SPLabel! {
        didSet {
            codeWarningLabel.textInsets = AuthenticationConstants.warningInsets
            codeWarningLabel.textColor = .simplenoteRed60Color
            codeWarningLabel.isHidden = true
        }
    }

    /// # Primary Action: LogIn / SignUp
    ///
    @IBOutlet private var primaryActionButton: SPSquaredButton! {
        didSet {
            primaryActionButton.setTitleColor(.white, for: .normal)
            primaryActionButton.accessibilityIdentifier = "Main Action"
        }
    }

    /// # Primary Action Spinner!
    ///
    @IBOutlet private var primaryActionSpinner: UIActivityIndicatorView! {
        didSet {
            primaryActionSpinner.style = .medium
            primaryActionSpinner.color = .white
        }
    }

    /// # Forgot Password Action
    ///
    @IBOutlet private var secondaryActionButton: UIButton! {
        didSet {
            secondaryActionButton.setTitleColor(.simplenoteBlue60Color, for: .normal)
            secondaryActionButton.titleLabel?.textAlignment = .center
            secondaryActionButton.titleLabel?.numberOfLines = 0
        }
    }

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

    /// # Actions Separator: Container
    ///
    @IBOutlet private var actionsSeparator: UIView!

    /// # Tertiary Separator: Label (Or)
    ///
    @IBOutlet private var actionsSeparatorLabel: UILabel! {
        didSet {
            actionsSeparatorLabel.text = AuthenticationStrings.separatorText
        }
    }

    /// # Tertiary Action: WPCOM SSO
    ///
    @IBOutlet private var tertiaryActionButton: SPSquaredButton! {
        didSet {
            tertiaryActionButton.setTitleColor(.white, for: .normal)
            tertiaryActionButton.backgroundColor = .simplenoteWPBlue50Color
        }
    }
    
    /// # Tertiary Action:
    ///
    @IBOutlet private var quaternaryActionButton: SPSquaredButton! {
        didSet {
            quaternaryActionButton.setTitleColor(.black, for: .normal)
            quaternaryActionButton.backgroundColor = .clear
            quaternaryActionButton.layer.borderWidth = 1
            quaternaryActionButton.layer.borderColor = UIColor.black.cgColor
        }
    }

    /// # All of the Visible InputView(s)
    ///
    private var visibleInputViews: [SPTextInputView] {
        [emailInputView, passwordInputView, codeInputView].filter { inputView in
            inputView.isHidden == false
        }
    }
    
    /// # All of the Action Views
    ///
    private var allActionViews: [UIButton] {
        [primaryActionButton, secondaryActionButton, tertiaryActionButton, quaternaryActionButton]
    }

    /// # Simperium's Authenticator Instance
    ///
    private let controller: SPAuthHandler

    /// # Simperium's Validator
    ///
    private lazy var validator = AuthenticationValidator()

    /// # Indicates if we've got valid Credentials. Doesn't display any validation warnings onscreen
    ///
    private var isInputValid: Bool {
        return performUsernameValidation() == .success && performPasswordValidation() == .success && performCodeValidation() == .success
    }

    /// # Returns the EmailInputView's Text: When empty this getter returns an empty string, instead of nil
    ///
    private var email: String {
        state.username
    }

    /// # Returns the PasswordInputView's Text: When empty this getter returns an empty string, instead of nil
    ///
    private var password: String {
        state.password
    }

    /// Indicates if we must nuke the Password Field's contents whenever the App becomes active
    ///
    private var mustResetPasswordField = false

    /// # Authentication Mode: Signup / Login with Password / Login with Link
    ///
    private let mode: AuthenticationMode
    
    /// # State: Allows us to preserve State, when dealing with a multi staged flow
    ///
    private var state: AuthenticationState {
        didSet {
            ensureStylesMatchValidationState()
            ensureWarningsAreDismissedWhenNeeded()
        }
    }

    /// Indicates if the Extended Debug Mode is enabled
    ///
    var debugEnabled = false

    /// NSCodable Required Initializer
    ///
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Designated Initializer
    ///
    init(controller: SPAuthHandler, mode: AuthenticationMode = .requestLoginCode, state: AuthenticationState = .init()) {
        self.controller = controller
        self.mode = mode
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - Overridden Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        startListeningToNotifications()

        refreshVisibleElements()
        refreshActionViews()
        reloadInputViewsFromState()

        // hiding text from back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ensureStylesMatchValidationState()
        ensureNavigationBarIsVisible()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Note: running becomeFirstResponder in `viewWillAppear` has the weird side effect of breaking caret
        // repositioning in the Text Field. Seriously.
        // Ref. https://github.com/Automattic/simplenote-ios/issues/453
        //
        visibleInputViews.first?.becomeFirstResponder()
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

    func refreshVisibleElements() {
        let visibleElements = mode.visibleElements
        
        emailInputView.isHidden         = !visibleElements.contains(.username)
        passwordInputView.isHidden      = !visibleElements.contains(.password)
        codeInputView.isHidden          = !visibleElements.contains(.code)
        actionsSeparator.isHidden       = !visibleElements.contains(.actionSeparator)
    }
    
    func refreshActionViews() {
        let viewMap: [AuthenticationActionName: UIButton] = [
            .primary: primaryActionButton,
            .secondary: secondaryActionButton,
            .tertiary: tertiaryActionButton,
            .quaternary: quaternaryActionButton
        ]
        
        for actionView in allActionViews {
            actionView.isHidden = true
        }

        for descriptor in mode.actions {
            guard let actionView = viewMap[descriptor.name] else {
                assertionFailure()
                continue
            }

            if let title = descriptor.text {
                actionView.setTitle(title, for: .normal)
            }
            
            if let attributedTitle = descriptor.attributedText {
                actionView.setAttributedTitle(attributedTitle, for: .normal)
            }

            actionView.addTarget(self, action: descriptor.selector, for: .touchUpInside)
            actionView.isHidden = false
        }
    }
    
    func reloadInputViewsFromState() {
        emailInputView.text = state.username
        passwordInputView.text = state.password
        codeInputView.text = state.code
    }

    func ensureStylesMatchValidationState() {
        primaryActionButton.backgroundColor = isInputValid ? .simplenoteBlue50Color : .simplenoteGray20Color
    }

    @objc
    func applicationDidBecomeActive() {
        ensurePasswordFieldIsReset()
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
    }

    private func unlockInterface() {
        view.isUserInteractionEnabled = true
        primaryActionSpinner.stopAnimating()
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
        
        guard let primaryActionDescriptor = mode.actions.first(where: { $0.name == .primary}) else {
            assertionFailure()
            return
        }

        perform(primaryActionDescriptor.selector)
    }
    
    @IBAction func performLogInWithPassword() {
        guard ensureWarningsAreOnScreenWhenNeeded() else {
            return
        }

        if mustUpgradePasswordStrength() {
            performCredentialsValidation()
            return
        }

        performSimperiumAuthentication()
    }
    
    @IBAction func requestLogInCode() {
        guard ensureWarningsAreOnScreenWhenNeeded() else {
            return
        }
        
        lockdownInterface()

        controller.requestLoginEmail(username: email) { error in
// TODO: 429 (Rate Limited)? push PW auth instead

            if let error {
                self.handleError(error: error)
            } else {
                self.presentCodeInterface()
                SPTracker.trackUserRequestedLoginLink()
            }

            self.unlockInterface()
        }
    }
    
    @IBAction func performLogInWithCode() {
        Task { @MainActor in
            await performLogInWithCodeInTask()
        }
    }
    
    @MainActor
    private func performLogInWithCodeInTask() async {
        lockdownInterface()
        
        do {
            try await controller.loginWithCode(username: state.username, code: state.code)
            SPTracker.trackUserConfirmedLoginLink()
        } catch let error as SPAuthError {
            self.handleError(error: error)
        } catch {
// TODO: Fixme
        }
        
        unlockInterface()
    }
    
    @IBAction func performLogInWithWPCOM() {
        WPAuthHandler.presentWordPressSSO(from: self)
    }
    
    @IBAction func performSignUp() {
        guard ensureWarningsAreOnScreenWhenNeeded() else {
            return
        }

        lockdownInterface()

        controller.signupWithCredentials(username: email) { [weak self] error in
            guard let self = self else {
                return
            }

            if let error = error {
                self.handleError(error: error)
            } else {
                self.presentSignupVerification()
            }

            self.unlockInterface()
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
    
    @IBAction func presentPasswordInterface() {
        let viewController = SPAuthViewController(controller: controller, mode: .loginWithPassword, state: state)
        navigationController?.pushViewController(viewController, animated: true)
    }
}


// MARK: - Navigation Helpers
//
private extension SPAuthViewController {

    func presentSignupVerification() {
        let viewController = SignupVerificationViewController(email: email)
        viewController.title = title
        navigationController?.pushViewController(viewController, animated: true)
    }
        
    func presentCodeInterface() {
        let viewController = SPAuthViewController(controller: controller, mode: .loginWithCode, state: state)
        navigationController?.pushViewController(viewController, animated: true)
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
        switch error {
        case .signupUserAlreadyExists:
            presentUserAlreadyExistsError(error: error)
        case .compromisedPassword:
            presentPasswordCompromisedError(error: error)
        case .unverifiedEmail:
            presentUserUnverifiedError(error: error, email: email)
        case .unknown(let statusCode, let response, let error) where debugEnabled:
            let details = NSAttributedString.stringFromNetworkError(statusCode: statusCode, response: response, error: error)
            presentDebugDetails(details: details)
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

    func presentPasswordCompromisedError(error: SPAuthError) {
        let alertController = UIAlertController(title: error.title, message: error.message, preferredStyle: .alert)
        alertController.addDefaultActionWithTitle(AuthenticationStrings.compromisedAlertReset) { _ in
            self.presentPasswordReset()
        }
        alertController.addCancelActionWithTitle(AuthenticationStrings.compromisedAlertCancel)

        present(alertController, animated: true, completion: nil)
    }

    func presentUserUnverifiedError(error: SPAuthError, email: String) {
        let alertController = UIAlertController(title: error.title, message: error.message, preferredStyle: .alert)
        alertController.addCancelActionWithTitle(AuthenticationStrings.unverifiedCancelText)
        alertController.addDefaultActionWithTitle(AuthenticationStrings.unverifiedActionText) { [weak self] _ in
            let spinnerVC = SpinnerViewController()
            self?.present(spinnerVC, animated: false, completion: nil)

            AccountRemote().verify(email: email) { result in
                spinnerVC.dismiss(animated: false, completion: nil)
                var alert: UIAlertController
                switch result {
                case .success:
                    alert = UIAlertController.dismissableAlert(title: AuthenticationStrings.verificationSentTitle,
                                                               message: String(format: AuthenticationStrings.verificationSentTemplate, email))
                case .failure:
                    alert = UIAlertController.dismissableAlert(title: AuthenticationStrings.unverifiedErrorTitle,
                                                               message: AuthenticationStrings.unverifiedErrorMessage)
                }
                self?.present(alert, animated: true, completion: nil)
            }
        }

        present(alertController, animated: true, completion: nil)
    }

    func presentDebugDetails(details: NSAttributedString) {
        let supportViewController = SPDiagnosticsViewController()
        supportViewController.attributedText = details

        let navigationController = SPNavigationController(rootViewController: supportViewController)
        navigationController.modalPresentationStyle = .formSheet

        present(navigationController, animated: true, completion: nil)
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
        let loginViewController = SPAuthViewController(controller: controller, mode: .loginWithPassword, state: state)
        loginViewController.loadViewIfNeeded()

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
    
    func displayCodeValidationWarning(_ string: String) {
        codeWarningLabel.text = string
        refreshCodeInput(inErrorState: true)
    }

    func dismissAllValidationWarnings() {
        refreshEmailInput(inErrorState: false)
        refreshPasswordInput(inErrorState: false)
    }
    
    func dismissEmailValidationWarning() {
        refreshEmailInput(inErrorState: false)
    }

    func dismissPasswordValidationWarning() {
        refreshPasswordInput(inErrorState: false)
    }
    
    func dismissCodeValidationWarning() {
        refreshCodeInput(inErrorState: false)
    }

    func refreshEmailInput(inErrorState: Bool) {
        emailWarningLabel.animateVisibility(isHidden: !inErrorState)
        emailInputView.inErrorState = inErrorState
    }

    func refreshPasswordInput(inErrorState: Bool) {
        passwordWarningLabel.animateVisibility(isHidden: !inErrorState)
        passwordInputView.inErrorState = inErrorState
    }
    
    func refreshCodeInput(inErrorState: Bool) {
        codeWarningLabel.animateVisibility(isHidden: !inErrorState)
        codeInputView.inErrorState = inErrorState
    }
}

// MARK: - Validation
//
private extension SPAuthViewController {

    func performUsernameValidation() -> AuthenticationValidator.Result {
        guard mode.visibleElements.contains(.username) else {
            return .success
        }

        return validator.performUsernameValidation(username: email)
    }

    /// When we're in `.login` mode, password requirements are relaxed (since we must allow users with old passwords to sign in).
    /// That's where the `validationStyle` comes in.
    ///
    func performPasswordValidation() -> AuthenticationValidator.Result {
        guard mode.visibleElements.contains(.password) else {
            return .success
        }

        return validator.performPasswordValidation(username: email, password: password, style: mode.validationStyle)
    }
    
    func performCodeValidation() -> AuthenticationValidator.Result {
        guard mode.visibleElements.contains(.code) else {
            return .success
        }
        
        return validator.performCodeValidation(code: state.code)
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
        let codeValidationResult = performCodeValidation()

        if usernameValidationResult != .success {
            displayEmailValidationWarning(usernameValidationResult.description)
        }

        if passwordValidationResult != .success {
            displayPasswordValidationWarning(passwordValidationResult.description)
        }
        
        if codeValidationResult != .success {
            displayCodeValidationWarning(codeValidationResult.description)
        }

        return usernameValidationResult == .success && passwordValidationResult == .success && codeValidationResult == .success
    }

    func ensureWarningsAreDismissedWhenNeeded() {
        if performUsernameValidation() == .success {
            dismissEmailValidationWarning()
        }

        if performPasswordValidation() == .success {
            dismissPasswordValidationWarning()
        }
        
        if performCodeValidation() == .success {
            dismissCodeValidationWarning()
        }
    }
}


// MARK: - UITextFieldDelegate Conformance
//
extension SPAuthViewController: SPTextInputViewDelegate {

    func textInputDidChange(_ textInput: SPTextInputView) {
        switch textInput {
        case emailInputView:
            state.username = textInput.text ?? ""
        case passwordInputView:
            state.password = textInput.text ?? ""
        case codeInputView:
            state.code = textInput.text ?? ""
        default:
            break
        }
    }

    func textInputShouldReturn(_ textInput: SPTextInputView) -> Bool {
        switch textInput {
        case emailInputView:
            switch performUsernameValidation() {
            case .success:
                if mode.visibleElements.contains(.password) {
                    passwordInputView.becomeFirstResponder()
                } else {
                    performPrimaryActionIfPossible()
                }

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

        case codeInputView:
            switch performCodeValidation() {
            case .success:
                performPrimaryActionIfPossible()
                
            case let error:
                displayCodeValidationWarning(error.description)
            }
            
        default:
            break
        }

        return false
    }
}


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

enum AuthenticationActionName {
    case primary
    case secondary
    case tertiary
    case quaternary
}

struct AuthenticationAction {
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
    let actions: [AuthenticationAction]
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
                        AuthenticationAction(name: .primary,
                                             selector: #selector(SPAuthViewController.performLogInWithPassword),
                                             text: PasswordStrings.login,
                                             attributedText: nil),
                        AuthenticationAction(name: .secondary,
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
                        AuthenticationAction(name: .primary,
                                            selector: #selector(SPAuthViewController.requestLogInCode),
                                            text: RequestCodeStrings.loginWithEmail,
                                            attributedText: nil),
                        AuthenticationAction(name: .tertiary,
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
                        AuthenticationAction(name: .primary,
                                            selector: #selector(SPAuthViewController.performLogInWithCode),
                                            text: LoginWithCodeStrings.login,
                                            attributedText: nil),
                        AuthenticationAction(name: .quaternary,
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
                        AuthenticationAction(name: .primary,
                                            selector: #selector(SPAuthViewController.performSignUp),
                                            text: SignupStrings.signup,
                                            attributedText: nil),
                        AuthenticationAction(name: .secondary,
                                            selector: #selector(SPAuthViewController.presentTermsOfService),
                                            text: nil,
                                            attributedText: SignupStrings.termsOfService)
                     ])
    }
}


// MARK: - Authentication Strings
//
private enum AuthenticationStrings {
    static let separatorText                = NSLocalizedString("Or", comment: "Or, used as a separator between Actions")
    static let emailPlaceholder             = NSLocalizedString("Email", comment: "Email TextField Placeholder")
    static let passwordPlaceholder          = NSLocalizedString("Password", comment: "Password TextField Placeholder")
    static let codePlaceholder              = NSLocalizedString("Code", comment: "Code TextField Placeholder")
    static let acceptActionText             = NSLocalizedString("Accept", comment: "Accept Action")
    static let cancelActionText             = NSLocalizedString("Cancel", comment: "Cancel Action")
    static let loginActionText              = NSLocalizedString("Log In", comment: "Log In Action")
    static let compromisedAlertCancel       = NSLocalizedString("Cancel", comment: "Cancel action for password alert")
    static let compromisedAlertReset        = NSLocalizedString("Change Password", comment: "Change password action")
    static let unverifiedCancelText         = NSLocalizedString("Ok", comment: "Email unverified alert dismiss")
    static let unverifiedActionText         = NSLocalizedString("Resend Verification Email", comment: "Send email verificaiton action")
    static let unverifiedErrorTitle         = NSLocalizedString("Request Error", comment: "Request error alert title")
    static let unverifiedErrorMessage       = NSLocalizedString("There was an preparing your verification email, please try again later", comment: "Request error alert message")
    static let verificationSentTitle        = NSLocalizedString("Check your Email", comment: "Vefification sent alert title")
    static let verificationSentTemplate     = NSLocalizedString("We’ve sent a verification email to %1$@. Please check your inbox and follow the instructions.", comment: "Confirmation that an email has been sent")
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

// MARK: - Authentication Constants
//
private enum AuthenticationConstants {
    static let accessoryViewInsets  = NSDirectionalEdgeInsets(top: .zero, leading: 16, bottom: .zero, trailing: 16)
    static let warningInsets        = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
}
