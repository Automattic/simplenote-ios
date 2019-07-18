import Foundation
import UIKit
import SafariServices


// MARK: - SPLoginViewController
//
class SPLoginViewController: UIViewController {

    /// Email Input
    ///
    @IBOutlet private var emailInputView: SPTextInputView! {
        didSet {
            emailInputView.backgroundColor = .clear
            emailInputView.keyboardType = .emailAddress
            emailInputView.placeholder = LoginStrings.emailPlaceholder
            emailInputView.returnKeyType = .next
            emailInputView.rightView = onePasswordButton
            emailInputView.rightViewMode = .always
            emailInputView.rightViewInsets = Constants.onePasswordInsets
            emailInputView.textColor = .simplenoteAlmostBlack()
        }
    }

    /// Password Input
    ///
    @IBOutlet private var passwordInputView: SPTextInputView! {
        didSet {
            passwordInputView.backgroundColor = .clear
            passwordInputView.isSecureTextEntry = true
            passwordInputView.placeholder = LoginStrings.passwordPlaceholder
            passwordInputView.returnKeyType = .done
            passwordInputView.rightView = revealPasswordButton
            passwordInputView.rightViewMode = .always
            passwordInputView.rightViewInsets = Constants.onePasswordInsets
            passwordInputView.textColor = .simplenoteAlmostBlack()
        }
    }

    /// Login Action
    ///
    @IBOutlet private var loginButton: SPSquaredButton! {
        didSet {
            loginButton.setTitle(LoginStrings.loginActionText, for: .normal)
            loginButton.setTitleColor(.white, for: .normal)
        }
    }

    /// Forgot Password Action
    ///
    @IBOutlet private var forgotButton: UIButton! {
        didSet {
            forgotButton.setTitle(LoginStrings.forgotActionText, for: .normal)
            forgotButton.setTitleColor(.simplenoteLightNavy(), for: .normal)
        }
    }

    /// 1Password Button
    ///
    private lazy var onePasswordButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(.onePasswordImage, for: .normal)
        button.tintColor = .simplenoteSlateGrey()
        button.addTarget(self, action: #selector(onePasswordWasPressed), for: .touchUpInside)
        button.sizeToFit()
        return button
    }()

    /// Reveal Password Button
    ///
    private lazy var revealPasswordButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(.visibilityOffImage, for: .normal)
        button.tintColor = .simplenoteSlateGrey()
        button.addTarget(self, action: #selector(revealPasswordWasPressed), for: .touchUpInside)
        button.sizeToFit()
        return button
    }()

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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailInputView.becomeFirstResponder()
        refreshButtonsStyle()
    }
}


// MARK: - Actions
//
extension SPLoginViewController {

    @IBAction func loginWasPressed() {
// TODO
    }

    @IBAction func forgotWasPressed() {
        let email = emailInputView.text ?? String()
        presentPasswordReset(for: email)
    }

    @IBAction func onePasswordWasPressed() {
// TODO
    }

    @IBAction func revealPasswordWasPressed() {
// TODO
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
    static let title                = NSLocalizedString("Log In", comment: "LogIn Interface Title")
    static let emailPlaceholder     = NSLocalizedString("Email", comment: "Email TextField Placeholder")
    static let passwordPlaceholder  = NSLocalizedString("Password", comment: "Password TextField Placeholder")
    static let loginActionText      = NSLocalizedString("Log In", comment: "Log In Action")
    static let forgotActionText     = NSLocalizedString("Forgotten password?", comment: "Password Reset Action")
}

private struct Constants {
    static let onePasswordInsets    = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
}
