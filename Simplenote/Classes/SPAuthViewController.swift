import Foundation
import UIKit
import SafariServices
import SwiftUI
import SimplenoteEndpoints


// MARK: - SPAuthViewController
//
class SPAuthViewController: UIViewController {

    /// # Links to the StackView and the container view
    ///
    @IBOutlet private var stackViewTopConstraint: NSLayoutConstraint!

    /// # StackView: Contains the entire UI
    ///
    @IBOutlet private var stackView: UIStackView!

    /// # Header: Container View
    ///
    @IBOutlet private var headerContainerView: UIView!
    
    /// # Header: Title Label
    ///
    @IBOutlet private var headerLabel: SPLabel!

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
        performInputElementsValidation().values.allSatisfy { result in
            result == .success
        }
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

        refreshHeaderView()
        refreshInputViews()
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

    func refreshHeaderView() {
        let headerText = mode.buildHeaderText(email: email)

        headerLabel.attributedText = headerText
        headerContainerView.isHidden = headerText == nil
    }
    
    func refreshInputViews() {
        let inputElements = mode.inputElements
        
        emailInputView.isHidden     = !inputElements.contains(.username)
        passwordInputView.isHidden  = !inputElements.contains(.password)
        codeInputView.isHidden      = !inputElements.contains(.code)
        actionsSeparator.isHidden   = !inputElements.contains(.actionSeparator)
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
extension SPAuthViewController {

    /// Whenever the input is Valid, we'll perform the Primary Action
    ///
    func performPrimaryActionIfPossible() {
        guard ensureWarningsAreOnScreenWhenNeeded() else {
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

        Task { @MainActor in
            await requestLogInCodeAsync()
        }
    }
    
    @MainActor
    private func requestLogInCodeAsync() async {
        lockdownInterface()

        do {
            try await controller.requestLoginEmail(username: email)
            self.presentCodeInterface()
            SPTracker.trackLoginLinkRequested()
            
        } catch SPAuthError.tooManyAttempts {
            self.presentPasswordInterfaceWithRateLimitingHeader()

        } catch {
            let error = error as? SPAuthError ?? .generic
            self.handleError(error: error)
        }
        
        self.unlockInterface()
    }

    /// Requests a new Login Code, without pushing any secondary UI on success
    ///
    @IBAction func requestLogInCodeAndDontPush() {
        Task { @MainActor in
            await self.requestLogInCodeAndDontPushAsync()
        }
    }

    /// Requests a new Login Code, without pushing any secondary UI on success. Asynchronous API!
    ///
    @MainActor
    private func requestLogInCodeAndDontPushAsync() async {
        do {
            try await controller.requestLoginEmail(username: email)
        } catch {
            let error = error as? SPAuthError ?? .generic
            self.handleError(error: error)
        }
        
        SPTracker.trackLoginLinkRequested()
    }
    
    @IBAction func performLogInWithCode() {
        guard ensureWarningsAreOnScreenWhenNeeded() else {
            return
        }

        Task { @MainActor in
            lockdownInterface()
            
            do {
                try await controller.loginWithCode(username: state.username, code: state.code)
                SPTracker.trackLoginLinkConfirmationSuccess()
            } catch {
                /// Errors will always be of the `SPAuthError` type. Let's switch to Typed Errors, as soon as we migrate over to Xcode 16
                let error = error as? SPAuthError ?? .generic
                self.handleError(error: error)

                SPTracker.trackLoginLinkConfirmationFailure()
            }
            
            unlockInterface()
        }
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
        presentPasswordInterfaceWithHeader(header: AuthenticationStrings.loginWithEmailEmailHeader)
    }
    
    @IBAction func presentPasswordInterfaceWithRateLimitingHeader() {
        presentPasswordInterfaceWithHeader(header: AuthenticationStrings.loginWithEmailLimitHeader)
    }

    @IBAction func presentPasswordInterfaceWithHeader(header: String?) {
        let viewController = SPAuthViewController(controller: controller, mode: .loginWithPassword(header: header), state: state)
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
        case .requestNotFound:
            presentLoginCodeExpiredError()
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
    
    func presentLoginCodeExpiredError() {
        let alertController = UIAlertController.buildLoginCodeNotFoundAlert {
            self.requestLogInCodeAndDontPush()
        }
        
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
        let loginViewController = SPAuthViewController(controller: controller, mode: .loginWithPassword(), state: state)
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

    /// When we're in `.login` mode, password requirements are relaxed (since we must allow users with old passwords to sign in).
    /// That's where the `validationStyle` comes in.
    ///
    func performInputElementsValidation() -> [AuthenticationInputElements: AuthenticationValidator.Result] {
        var result = [AuthenticationInputElements: AuthenticationValidator.Result]()
        
        if mode.inputElements.contains(.username) {
            result[.username] = validator.performUsernameValidation(username: email)
        }
        
        if mode.inputElements.contains(.password) {
            result[.password] = validator.performPasswordValidation(username: email, password: password, style: mode.validationStyle)
        }
        
        if mode.inputElements.contains(.code) {
            result[.code] = validator.performCodeValidation(code: state.code)
        }
        
        return result
    }

    /// Whenever we're in `.login` mode, and the password is valid in `.legacy` terms (but invalid in `.strong` mode), we must request the
    /// user to reset the password associated to his/her account.
    ///
    func mustUpgradePasswordStrength() -> Bool {
        validator.performPasswordValidation(username: email, password: password, style: .strong) != .success
    }

    /// Validates all of the Input Fields, and presents warnings accordingly.
    /// - Returns true: When all validations are passed
    ///
    func ensureWarningsAreOnScreenWhenNeeded() -> Bool {
        let validationMap = performInputElementsValidation()

        if let result = validationMap[.username], result != .success {
            displayEmailValidationWarning(result.description)
        }

        if let result = validationMap[.password], result != .success {
            displayPasswordValidationWarning(result.description)
        }
        
        if let result = validationMap[.code], result != .success {
            displayCodeValidationWarning(result.description)
        }

        return validationMap.values.allSatisfy { result in
            result == .success
        }
    }

    /// Validates all of the Input Fields, and dismisses validation warnings, when possible
    ///
    func ensureWarningsAreDismissedWhenNeeded() {
        let validationMap = performInputElementsValidation()

        if validationMap[.username] == .success {
            dismissEmailValidationWarning()
        }

        if validationMap[.password] == .success {
            dismissPasswordValidationWarning()
        }
        
        if validationMap[.code] == .success {
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
        performPrimaryActionIfPossible()
        return false
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
    static let loginWithEmailEmailHeader    = NSLocalizedString("Enter the password for the account {{EMAIL}}", comment: "Header for Login With Password. Please preserve the {{EMAIL}} substring")
    static let loginWithEmailLimitHeader    = NSLocalizedString("Log in with email failed, please enter your password", comment: "Header for Enter Password UI, when the user performed too many requests")
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


// MARK: - Authentication Constants
//
private enum AuthenticationConstants {
    static let accessoryViewInsets  = NSDirectionalEdgeInsets(top: .zero, leading: 16, bottom: .zero, trailing: 16)
    static let warningInsets        = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
}
