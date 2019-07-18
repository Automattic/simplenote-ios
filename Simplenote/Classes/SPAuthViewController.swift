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
            emailInputView.placeholder = LoginStrings.emailPlaceholder
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
    @IBOutlet private var primaryActionButton: SPSquaredButton! {
        didSet {
            primaryActionButton.setTitle(LoginStrings.loginActionText, for: .normal)
            primaryActionButton.setTitleColor(.white, for: .normal)
        }
    }

    /// Forgot Password Action
    ///
    @IBOutlet private var secondaryActionButton: UIButton! {
        didSet {
            secondaryActionButton.setTitle(LoginStrings.forgotActionText, for: .normal)
            secondaryActionButton.setTitleColor(.simplenoteLightNavy(), for: .normal)
            secondaryActionButton.titleLabel?.textAlignment = .center
        }
    }

    /// 1Password Button
    ///
    private lazy var onePasswordButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(.onePasswordImage, for: .normal)
        button.tintColor = .simplenoteSlateGrey()
// TODO
//        button.addTarget(self, action: #selector(onePasswordWasPressed), for: .touchUpInside)
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
// TODO
//        button.addTarget(self, action: #selector(revealPasswordWasPressed), for: [.touchDown])
//        button.addTarget(self, action: #selector(revealPasswordWasReleased), for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
        button.sizeToFit()
        return button
    }()

    /// Simperium's Authenticator Instance
    ///
    private let controller: SPAuthenticationController

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
        self.controller = SPAuthenticationController(simperiumService: simperiumAuthenticator)
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
extension SPAuthViewController {

    @IBAction func primaryActionWasPressed() {

    }

    @IBAction func secondaryActionWasPressed() {

    }

    private func signupWasPressed() {
        // TODO
        //        [SPTracker trackUserAccountCreated];
    }

    private func loginWasPressed() {
// TODO
        SPTracker.trackUserSignedIn()
    }

    private func forgotWasPressed() {
        let email = emailInputView.text ?? String()
        presentPasswordReset(for: email)
    }

    private func onePasswordWasPressed() {
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

            self.loginWasPressed()
            SPTracker.trackOnePasswordLoginSuccess()
        }
    }

    private func revealPasswordWasPressed() {
        passwordInputView.isSecureTextEntry = false
    }

    private func revealPasswordWasReleased() {
        passwordInputView.isSecureTextEntry = true
    }
}


// MARK: - Private
//
private extension SPAuthViewController {

    func setupNavigationController() {
        title = LoginStrings.title
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.applySimplenoteLightStyle()
    }

    func refreshButtonsStyle() {
        primaryActionButton.backgroundColor = isInputValid ? .simplenoteLightNavy() : .simplenotePalePurple()
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

    func presentTermsOfService() {
        guard let targetURL = URL(string: kSimperiumTermsOfServiceURL) else {
            return
        }

        let safariViewController = SFSafariViewController(url: targetURL)
        safariViewController.modalPresentationStyle = .overFullScreen
        present(safariViewController, animated: true, completion: nil)
    }
}


//- (void)reloadOnePassword
//{
//    // Update the OnePassword Handler
//    SEL hander = self.signingIn ? @selector(findLoginFromOnePassword:) : @selector(saveLoginToOnePassword:);
//    [self.onePasswordButton removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
//    [self.onePasswordButton addTarget:self action:hander forControlEvents:UIControlEventTouchUpInside];
//
//    // Show the OnePassword view, if it's available
//    BOOL isOnePasswordAvailable         = [[OnePasswordExtension sharedExtension] isAppExtensionAvailable];
//    self.usernameField.rightViewMode    = isOnePasswordAvailable ? UITextFieldViewModeAlways : UITextFieldViewModeNever;
//}


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


// MARK: - Private Types
//
private struct LoginStrings {
    static let title                = NSLocalizedString("Log In", comment: "LogIn Interface Title")
    static let emailPlaceholder     = NSLocalizedString("Email", comment: "Email TextField Placeholder")
    static let passwordPlaceholder  = NSLocalizedString("Password", comment: "Password TextField Placeholder")
    static let loginActionText      = NSLocalizedString("Log In", comment: "Log In Action")
    static let forgotActionText     = NSLocalizedString("Forgotten password?", comment: "Password Reset Action")
}

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
