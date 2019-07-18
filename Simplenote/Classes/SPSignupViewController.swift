import Foundation
import UIKit
import SafariServices


// MARK: - SPSignupViewController
//
class SPSignupViewController: UIViewController {

    /// Email Input
    ///
    @IBOutlet private var emailTextInputView: SPTextInputView!

    /// Password Input
    ///
    @IBOutlet private var passwordTextInputView: SPTextInputView!

    /// SignUp Action
    ///
    @IBOutlet private var signupButton: SPSquaredButton!

    /// ToS Action
    ///
    @IBOutlet private var termsOfServiceButton: UIButton!

    /// 1Password Button
    ///
    private let onePasswordButton = UIButton(type: .custom)

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
extension SPSignupViewController {

    @IBAction func signupWasPressed() {
        // TODO
    }

    @IBAction func termsWasPressed() {
        presentTermsOfService()
    }

    @IBAction func onePasswordWasPressed() {
        // TODO
    }
}


// MARK: - Private
//
private extension SPSignupViewController {

    func setupNavigationController() {
        title = SignupStrings.title
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.applySimplenoteLightStyle()
    }

    func setupTextFields() {
        emailTextInputView.rightView = onePasswordButton
        emailTextInputView.rightViewMode = .always
        emailTextInputView.textColor = .simplenoteAlmostBlack()
        emailTextInputView.placeholder = SignupStrings.emailPlaceholder
        emailTextInputView.keyboardType = .emailAddress
        emailTextInputView.returnKeyType = .next
        emailTextInputView.backgroundColor = .clear

        passwordTextInputView.textColor = .simplenoteAlmostBlack()
        passwordTextInputView.placeholder = SignupStrings.passwordPlaceholder
        passwordTextInputView.isSecureTextEntry = true
        passwordTextInputView.returnKeyType = .done
        passwordTextInputView.backgroundColor = .clear
    }

    func setupActionButtons() {
        onePasswordButton.setImage(.onePasswordImage, for: .normal)
        onePasswordButton.sizeToFit()
        onePasswordButton.imageEdgeInsets = Constants.onePasswordInsets
        onePasswordButton.frame.size.width += Constants.onePasswordInsets.right
        onePasswordButton.addTarget(self, action: #selector(onePasswordWasPressed), for: .touchUpInside)

        signupButton.setTitle(SignupStrings.signupActionText, for: .normal)
        signupButton.setTitleColor(.white, for: .normal)
        signupButton.backgroundColor = .simplenoteLightNavy()

        let termsText = NSLocalizedString("By creating an account you agree to our Terms and Conditions",
                                          comment: "Terms of Service Legend")
        termsOfServiceButton.setTitle(termsText, for: .normal)
        termsOfServiceButton.titleLabel?.numberOfLines = 0
    }

    func refreshButtonsStyle() {
        signupButton.backgroundColor = isInputValid ? .simplenoteLightNavy() : .simplenotePalePurple()
    }

    func presentTermsOfService() {
        guard let targetURL = URL(string: kSimperiumTermsOfServiceURL) else {
            return
        }

        let safariViewController = SFSafariViewController(url: targetURL)
        safariViewController.modalPresentationStyle = .overFullScreen
        present(safariViewController, animated: true, completion: nil)
    }
}


// MARK: - Private Types
//
private struct SignupStrings {
    static let title                = NSLocalizedString("Sign Up", comment: "Sign Up Title")
    static let emailPlaceholder     = NSLocalizedString("Email", comment: "Email TextField Placeholder")
    static let passwordPlaceholder  = NSLocalizedString("Password", comment: "Password TextField Placeholder")
    static let signupActionText     = NSLocalizedString("Sign Up", comment: "Sign Up Action")
}

private struct Constants {
    static let onePasswordInsets    = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
}
