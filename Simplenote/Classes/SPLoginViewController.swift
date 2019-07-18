import Foundation
import UIKit
import SafariServices


// MARK: - SPLoginViewController
//
class SPLoginViewController: UIViewController {

    /// Email Input
    ///
    @IBOutlet private var emailTextInputView: SPTextInputView!

    /// Password Input
    ///
    @IBOutlet private var passwordTextInputView: SPTextInputView!

    /// Login Action
    ///
    @IBOutlet private var loginButton: SPSquaredButton!

    /// Forgot Password Action
    ///
    @IBOutlet private var forgotButton: UIButton!

    /// Simperium's Authenticator Instance
    ///
    private let authenticator: SPAuthenticator

    ///
    ///
    private var isInputValid: Bool {
// TODO
        return false
    }


    /// NSCodable Required Initializer
    ///
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Designated Initializer
    ///
    init(authenticator: SPAuthenticator) {
        self.authenticator = authenticator
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - Overridden Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        setupTextFields()
        setupActionButtons()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTextInputView.becomeFirstResponder()
    }
}


// MARK: - Actions
//
extension SPLoginViewController {

    @IBAction func loginWasPressed() {
// TODO
    }

    @IBAction func forgotWasPressed() {
        let email = emailTextInputView.text ?? ""
        presentPasswordReset(for: email)
    }
}


// MARK: - Private
//
private extension SPLoginViewController {

    func setupNavigationController() {
        title = LoginStrings.title
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.applySimplenoteLightStyle()
    }

    func setupTextFields() {
        emailTextInputView.textColor = .simplenoteAlmostBlack()
        emailTextInputView.placeholder = LoginStrings.emailPlaceholder
        emailTextInputView.keyboardType = .emailAddress
        emailTextInputView.returnKeyType = .next
        emailTextInputView.backgroundColor = .clear

        passwordTextInputView.textColor = .simplenoteAlmostBlack()
        passwordTextInputView.placeholder = LoginStrings.passwordPlaceholder
        passwordTextInputView.isSecureTextEntry = true
        passwordTextInputView.returnKeyType = .done
        passwordTextInputView.backgroundColor = .clear
    }

    func setupActionButtons() {
        loginButton.setTitle(LoginStrings.loginActionText, for: .normal)
        loginButton.backgroundColor = .simplenotePalePurple()
        loginButton.setTitleColor(.white, for: .normal)

        forgotButton.setTitle(LoginStrings.forgotActionText, for: .normal)
        forgotButton.setTitleColor(.simplenoteLightNavy(), for: .normal)
    }

    func refreshButtonsStyle() {
        loginButton.backgroundColor = isInputValid ? .simplenoteLightNavy() : .simplenotePalePurple()
    }

    func presentPasswordReset(for email: String) {
        let resetPasswordPath = kSimperiumForgotPasswordURL.appending("?email=\(email)")
        guard let forgotPasswordURL = URL(string: resetPasswordPath) else {
            return
        }

        let safariViewController = SFSafariViewController(url: forgotPasswordURL)
        safariViewController.modalPresentationStyle = .overFullScreen
        present(safariViewController, animated: true, completion: nil)
    }
}


// MARK: - Private Types
//
private struct LoginStrings {
    static let title                = NSLocalizedString("Log In", comment: "LogIn Title")
    static let emailPlaceholder     = NSLocalizedString("Email", comment: "Email TextField Placeholder")
    static let passwordPlaceholder  = NSLocalizedString("Password", comment: "Password TextField Placeholder")
    static let loginActionText      = NSLocalizedString("Log In", comment: "Log In Action")
    static let forgotActionText     = NSLocalizedString("Forgotten password?", comment: "Password Reset Action")
}
