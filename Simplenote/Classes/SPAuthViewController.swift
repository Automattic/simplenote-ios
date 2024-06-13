import Foundation
import UIKit
import SafariServices
import AuthenticationServices

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

    /// # Primary Action: LogIn / SignUp
    ///
    @IBOutlet private var primaryActionButton: SPSquaredButton! {
        didSet {
            primaryActionButton.setTitle(mode.primaryActionText, for: .normal)
            primaryActionButton.setTitleColor(.white, for: .normal)
            primaryActionButton.addTarget(self, action: mode.primaryActionSelector, for: .touchUpInside)
        }
    }

    /// # Passkey Button Action
    ///
    @IBOutlet weak var passkeySigninButton: SPSquaredButton! {
        didSet {
            passkeySigninButton.isHidden = !mode.isLogin
            passkeySigninButton.setTitle(AuthenticationStrings.passkeyActionButton, for: .normal)
            passkeySigninButton.setTitleColor(.white, for: .normal)
            passkeySigninButton.addTarget(self, action: #selector(passkeyAuthAction), for: .touchUpInside)
        }
    }

    /// # Primary Action Spinner!
    ///
    @IBOutlet private var primaryActionSpinner: UIActivityIndicatorView! {
        didSet {
            primaryActionSpinner.style = .medium
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

    /// # Passkey Action Spinner
    ///
    @IBOutlet weak var passkeyActivitySpinner: UIActivityIndicatorView! {
        didSet {
            passkeyActivitySpinner.style = .medium
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

        passwordInputView.isHidden = mode.isPasswordHidden

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
        passkeySigninButton.backgroundColor = isInputValid ? .simplenoteBlue50Color : .simplenoteGray20Color
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

        perform(mode.primaryActionSelector)
    }

    @IBAction func performLogIn() {
        guard ensureWarningsAreOnScreenWhenNeeded() else {
            return
        }

        if passwordInputView.isHidden == true && passwordInputView.text?.isEmpty == true {
            passwordInputView.isHidden = false
            return
        }

        if mustUpgradePasswordStrength() {
            performCredentialsValidation()
            return
        }

        performSimperiumAuthentication(username: email, password: password)
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

    @objc func passkeyAuthAction() {
        Task {
            //TODO: Handle errors
            //TODO: Handle email not valid
            try? await displayPasskeyAuthenticationOptions()
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

    private func presentSignupVerification() {
        let viewController = SignupVerificationViewController(email: email)
        viewController.title = title
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

    func performSimperiumAuthentication(username: String, password: String) {
        lockdownInterface()

        controller.loginWithCredentials(username: username, password: password) { error in
            if let error = error {
                self.handleError(error: error)
            } else {
                SPTracker.trackUserSignedIn()
            }
            self.unlockInterface()
        }
    }

    func performPasskeyAuthentication(with response: WebAuthnResponse) {
        let json = try! JSONEncoder().encode(response)
        // TODO We probably don't need to pass email since we are passing the id which is stored on gae
        var jsonObject = try! JSONSerialization.jsonObject(with: json, options: []) as! [String: Any]
        jsonObject["email"] = email
        let updatedJson = try! JSONSerialization.data(withJSONObject: jsonObject)

        Task {
            try? await AccountRemote().verifyPasskeyLogin(with: updatedJson)
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
        guard !mode.isPasswordHidden else {
            return .success
        }
        return validator.performPasswordValidation(username: email, password: password, style: mode.validationStyle)
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
                if mode.isPasswordHidden {
                    performPrimaryActionIfPossible()
                } else {
                    passwordInputView.becomeFirstResponder()
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

        default:
            break
        }

        return false
    }
}

// MARK: - ASAuthentication
//
extension SPAuthViewController: ASAuthorizationControllerDelegate {
    private func displayPasskeyAuthenticationOptions() async throws {
        guard let challenge = try await fetchAuthChallenge() else {
            return
        }

        // TODO add protection if challengeData could not be decoded
        let challengeData = try Data.decodeUrlSafeBase64(challenge.challenge)
        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: challenge.relayingParty)
        let request = provider.createCredentialAssertionRequest(challenge: challengeData)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    private func fetchAuthChallenge() async throws -> PasskeyAuthChallenge? {
        guard let data = try await AccountRemote().passkeyAuthChallenge(for: email) else {
            return nil
        }
        print("data")

        let challenge = try JSONDecoder().decode(PasskeyAuthChallenge.self, from: data)
        return challenge
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion {
            let id = credential.credentialID.base64EncodedString()
            let rawId = credential.credentialID.base64EncodedString()

            let response = WebAuthnResponse(
                id: id.toBase64url(),
                rawId: rawId.toBase64url(),
                response: WebAuthnResponse.Response(
                    clientDataJSON: credential.rawClientDataJSON.base64EncodedString(),
                    authenticatorData: credential.rawAuthenticatorData.base64EncodedString(),
                    signature: credential.signature.base64EncodedString(),
                    userHandle: credential.userID.base64EncodedString()
                )
            )

            performPasskeyAuthentication(with: response)
        }

    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        passwordInputView.isHidden = false
    }
}

extension SPAuthViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        view.window!
    }
}

struct PasskeyAuthChallenge: Decodable {
    let relayingParty: String
    let challenge: String

    enum CodingKeys: String, CodingKey {
        case relayingParty = "rpId"
        case challenge
    }
}

struct WebAuthnResponse: Codable {
    let id: String
    let rawId: String
    let response: Response
    var type: String = "public-key"

    struct Response: Codable {
        let clientDataJSON: String
        let authenticatorData: String
        let signature: String
        let userHandle: String
    }
}

// MARK: - AuthenticationMode: Signup / Login
//
struct AuthenticationMode {
    let title: String
    let validationStyle: AuthenticationValidator.Style
    let primaryActionSelector: Selector
    let primaryActionText: String
    let secondaryActionSelector: Selector
    let secondaryActionText: String?
    let secondaryActionAttributedText: NSAttributedString?
    let isPasswordHidden: Bool
    let isLogin: Bool
}

// MARK: - Default Operation Modes
//
extension AuthenticationMode {

    /// Login Operation Mode: Contains all of the strings + delegate wirings, so that the AuthUI handles authentication scenarios.
    ///
    static var login: AuthenticationMode {
        return .init(title: AuthenticationStrings.loginTitle,
                     validationStyle: .legacy,
                     primaryActionSelector: #selector(SPAuthViewController.performLogIn),
                     primaryActionText: AuthenticationStrings.loginPrimaryAction,
                     secondaryActionSelector: #selector(SPAuthViewController.presentPasswordReset),
                     secondaryActionText: AuthenticationStrings.loginSecondaryAction,
                     secondaryActionAttributedText: nil,
                     isPasswordHidden: true,
                     isLogin: true)
    }

    /// Signup Operation Mode: Contains all of the strings + delegate wirings, so that the AuthUI handles user account creation scenarios.
    ///
    static var signup: AuthenticationMode {
        return .init(title: AuthenticationStrings.signupTitle,
                     validationStyle: .strong,
                     primaryActionSelector: #selector(SPAuthViewController.performSignUp),
                     primaryActionText: AuthenticationStrings.signupPrimaryAction,
                     secondaryActionSelector: #selector(SPAuthViewController.presentTermsOfService),
                     secondaryActionText: nil,
                     secondaryActionAttributedText: AuthenticationStrings.signupSecondaryAttributedAction,
                     isPasswordHidden: true,
                     isLogin: false)
    }
}

// MARK: - Authentication Strings
//
private enum AuthenticationStrings {
    static let loginTitle                   = NSLocalizedString("Log In", comment: "LogIn Interface Title")
    static let loginPrimaryAction           = NSLocalizedString("Log In", comment: "LogIn Action")
    static let loginSecondaryAction         = NSLocalizedString("Forgotten password?", comment: "Password Reset Action")
    static let passkeyActionButton          = NSLocalizedString("Log In With Passkeys", comment: "Login with Passkey action")
    static let signupTitle                  = NSLocalizedString("Sign Up", comment: "SignUp Interface Title")
    static let signupPrimaryAction          = NSLocalizedString("Sign Up", comment: "SignUp Action")
    static let signupSecondaryActionPrefix  = NSLocalizedString("By creating an account you agree to our", comment: "Terms of Service Legend *PREFIX*: printed in dark color")
    static let signupSecondaryActionSuffix  = NSLocalizedString("Terms and Conditions", comment: "Terms of Service Legend *SUFFIX*: Concatenated with a space, after the PREFIX, and printed in blue")
    static let emailPlaceholder             = NSLocalizedString("Email", comment: "Email TextField Placeholder")
    static let passwordPlaceholder          = NSLocalizedString("Password", comment: "Password TextField Placeholder")
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
    static let accessoryViewInsets  = NSDirectionalEdgeInsets(top: .zero, leading: 16, bottom: .zero, trailing: 16)
    static let warningInsets        = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
}

// TODO Move this to a better place :)
extension Data {
    static func decodeUrlSafeBase64(_ value: String) throws -> Data {
        var stringtoDecode: String = value.replacingOccurrences(of: "-", with: "+")
        stringtoDecode = stringtoDecode.replacingOccurrences(of: "_", with: "/")
        switch stringtoDecode.utf8.count % 4 {
            case 2:
                stringtoDecode += "=="
            case 3:
                stringtoDecode += "="
            default:
                break
        }
        guard let data = Data(base64Encoded: stringtoDecode, options: [.ignoreUnknownCharacters]) else {
            throw NSError(domain: "decodeUrlSafeBase64", code: 1,
                        userInfo: [NSLocalizedDescriptionKey: "Can't decode base64 string"])
        }
        return data
    }
}
