import Foundation
import UIKit
import SafariServices


// MARK: - SPSignupViewController
//
class SPSignupViewController: UIViewController {

    /// Email Input
    ///
    @IBOutlet private var emailInputView: SPTextInputView! {
        didSet {
            emailInputView.keyboardType = .emailAddress
            emailInputView.placeholder = SignupStrings.emailPlaceholder
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
            passwordInputView.placeholder = SignupStrings.passwordPlaceholder
            passwordInputView.returnKeyType = .done
            passwordInputView.rightView = revealPasswordButton
            passwordInputView.rightViewMode = .always
            passwordInputView.rightViewInsets = Constants.onePasswordInsets
            passwordInputView.textColor = .simplenoteAlmostBlack()
        }
    }

    /// SignUp Action
    ///
    @IBOutlet private var signupButton: SPSquaredButton! {
        didSet {
            signupButton.setTitle(SignupStrings.signupActionText, for: .normal)
            signupButton.setTitleColor(.white, for: .normal)
        }
    }

    /// ToS Action
    ///
    @IBOutlet private var termsOfServiceButton: UIButton! {
        didSet {
            termsOfServiceButton.setTitle(SignupStrings.termsText, for: .normal)
            termsOfServiceButton.titleLabel?.numberOfLines = 0
            termsOfServiceButton.titleLabel?.textAlignment = .center
        }
    }

    /// OnePassword Button
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
        button.setImage(.visibilityOnImage, for: .highlighted)
        button.tintColor = .simplenoteSlateGrey()
        button.addTarget(self, action: #selector(revealPasswordWasPressed), for: [.touchDown])
        button.addTarget(self, action: #selector(revealPasswordWasReleased), for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
        button.sizeToFit()
        return button
    }()

    /// Simperium's Authenticator Instance
    ///
    private let simperiumAuthenticator: SPAuthenticator

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
    init(simperiumAuthenticator: SPAuthenticator) {
        self.simperiumAuthenticator = simperiumAuthenticator
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
extension SPSignupViewController {

    @IBAction func signupWasPressed() {
// TODO
    //        [SPTracker trackUserAccountCreated];
    }

    @IBAction func termsWasPressed() {
        presentTermsOfService()
    }

    @IBAction func onePasswordWasPressed() {
// TODO
    }

    @IBAction func revealPasswordWasPressed() {
        passwordInputView.isSecureTextEntry = false
    }

    @IBAction func revealPasswordWasReleased() {
        passwordInputView.isSecureTextEntry = true
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
    static let termsText            = NSLocalizedString("By creating an account you agree to our Terms and Conditions", comment: "Terms of Service Legend")
}

private struct Constants {
    static let onePasswordInsets    = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
}
