import Foundation
import UIKit
import SafariServices
import AuthenticationServices


// MARK: - SPOnboardingViewController
//
class SPOnboardingViewController: UIViewController, SPAuthenticationInterface {

    /// Top Label
    ///
    @IBOutlet var simplenoteLabel: UILabel!

    /// Header
    ///
    @IBOutlet var headerLabel: UILabel!

    /// SignUp Button
    ///
    @IBOutlet var signUpButton: SPSquaredButton!

    /// Login Button
    ///
    @IBOutlet var loginButton: UIButton!

    /// Simperium's Authenticator Instance
    ///
    var authenticator: SPAuthenticator?


    // MARK: - Overriden Properties

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var shouldAutorotate: Bool {
        return false
    }

    /// Deinitializer
    ///
    deinit {
        stopListeningToNotifications()
    }

    // MARK: - Overridden Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupNavigationController()
        setupLabels()
        setupActionButtons()
        setupAppleAuthentication()
        startListeningToNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ensureNavigationBarIsHidden()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        performPreexistingSignInWithAppleFlow()
    }
}


// MARK: - Initialization
//
private extension SPOnboardingViewController {

    func setupNavigationItem() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: String(), style: .plain, target: nil, action: nil)
    }

    func setupNavigationController() {
        navigationController?.navigationBar.applySimplenoteLightStyle()

        // All of the Authentication Flows are meant to be rendered in Light Mode
#if IS_XCODE_11
        if #available(iOS 13.0, *) {
            navigationController?.overrideUserInterfaceStyle = .light
        }
#endif
    }

    func setupActionButtons() {
        let simplenoteLightNavy = UIColor.color(name: .simplenoteLightNavy)

        signUpButton.setTitle(OnboardingStrings.signupText, for: .normal)
        signUpButton.setTitleColor(.white, for: .normal)
        signUpButton.backgroundColor = .color(name: .simplenoteMidBlue)

        loginButton.setTitle(OnboardingStrings.loginText, for: .normal)
        loginButton.setTitleColor(simplenoteLightNavy, for: .normal)
    }

    func setupLabels() {
        let simplenoteAlmostBlack = UIColor.color(name: .simplenoteAlmostBlack)

        simplenoteLabel.text = OnboardingStrings.brandText
        simplenoteLabel.textColor = simplenoteAlmostBlack

        headerLabel.text = OnboardingStrings.headerText
        headerLabel.textColor = simplenoteAlmostBlack

        if #available(iOS 11, *) {
            simplenoteLabel.adjustsFontSizeToFitWidth = true
            simplenoteLabel.font = .preferredFont(forTextStyle: .largeTitle)

            headerLabel.adjustsFontSizeToFitWidth = true
            headerLabel.font = .preferredFont(forTextStyle: .title3)
        }
    }

    func setupAppleAuthentication() {
        guard #available(iOS 13, *) else {
            return
        }

        SPAppleAuthManager.shared.presentationContextProvider = self
    }

    func ensureNavigationBarIsHidden() {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}


// MARK: - Actions
//
private extension SPOnboardingViewController {

    @IBAction func signupWasPressed() {
        presentAuthenticationInterface(mode: .signup)
    }

    @IBAction func loginWasPressed() {
        presentLoginSheet()
    }

    @IBAction func emailLoginWasPressed() {
        presentAuthenticationInterface(mode: .login)
    }

    @IBAction func dotcomLoginWasPressed() {
        presentWordpressSSO()
    }

    @available(iOS 13.0, *)
    @IBAction func aaplLoginWasPressed() {
        presentSignInWithApple()
    }
}


// MARK: - Presenting
//
private extension SPOnboardingViewController {

    func presentLoginSheet() {
        let emailButton = SPSquaredButton(type: .custom)
        emailButton.setTitle(OnboardingStrings.loginWithEmailText, for: .normal)
        emailButton.backgroundColor = .color(name: .simplenoteMidBlue)
        emailButton.addTarget(self, action: #selector(emailLoginWasPressed), for: .touchUpInside)

        let dotcomButton = SPSquaredButton(type: .custom)
        dotcomButton.setTitle(OnboardingStrings.loginWithDotcomText, for: .normal)
        dotcomButton.backgroundColor = .color(name: .simplenoteDeepSeaBlue)
        dotcomButton.addTarget(self, action: #selector(dotcomLoginWasPressed), for: .touchUpInside)

        let sheetController = SPSheetController()
        sheetController.insertButton(emailButton)
        sheetController.insertButton(dotcomButton)

        if #available(iOS 13.0, *) {
            let siwaButton = ASAuthorizationAppleIDButton(authorizationButtonType: .continue, authorizationButtonStyle: .black)
            siwaButton.addTarget(self, action: #selector(aaplLoginWasPressed), for: .touchUpInside)
            sheetController.insertButton(siwaButton)
        }

        sheetController.present(from: self)
    }

    func presentAuthenticationInterface(mode: AuthenticationMode) {
        guard let simperiumAuthenticator = authenticator else {
            fatalError("Missing Simperium Authenticator Instance")
        }

        let controller = SPAuthHandler(simperiumService: simperiumAuthenticator)
        let viewController = SPAuthViewController(controller: controller, mode: mode)
        navigationController?.pushViewController(viewController, animated: true)
    }

    func presentWordpressSSO() {
        WPAuthHandler.presentWordPressSSO(from: self)
    }


    @available(iOS 13.0, *)
    func presentSignInWithApple() {
        SPAppleAuthManager.shared.presentSignInWithApple { (credentials, error) in
            guard let credentials = credentials else {
                NSLog("### SIWA Error \(error)")
                return
            }

            NSLog("### SIWA Credentials")
            NSLog("###   User \(credentials.user)")
            NSLog("###   Name \(credentials.fullName)")
            NSLog("###   Email \(credentials.email)")
            NSLog("###   Token \(credentials.identityToken)")
            NSLog("###   Code \(credentials.authorizationCode)")
            NSLog("###   Status \(credentials.realUserStatus)")
        }
    }

    func performPreexistingSignInWithAppleFlow() {
        guard #available(iOS 13.0, *) else {
            return
        }

        SPAppleAuthManager.shared.presentExistingAccountSetupFlows { (credentials, error) in
            guard let credentials = credentials else {
                NSLog("### SIWA Error \(error)")
                return
            }


            NSLog("### SIWA Credentials")
            NSLog("###   User \(credentials.user)")
            NSLog("###   Name \(credentials.fullName)")
            NSLog("###   Email \(credentials.email)")
            NSLog("###   Token \(credentials.identityToken)")
            NSLog("###   Code \(credentials.authorizationCode)")
            NSLog("###   Status \(credentials.realUserStatus)")
        }
    }
}


// MARK: - Notifications
//
private extension SPOnboardingViewController {

    func startListeningToNotifications() {
        let name = NSNotification.Name(rawValue: kSignInErrorNotificationName)

        NotificationCenter.default.addObserver(self, selector: #selector(handleSignInError), name: name, object: nil)
    }

    func stopListeningToNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func handleSignInError(note: Notification) {
        let message = note.userInfo?[NSLocalizedDescriptionKey] as? String ?? SignInError.genericErrorText
        let alertController = UIAlertController(title: SignInError.title, message: message, preferredStyle: .alert)

        alertController.addDefaultActionWithTitle(SignInError.acceptButtonText)

        /// SFSafariViewController _might_ be onscreen
        presentedViewController?.dismiss(animated: true, completion: nil)
        present(alertController, animated: true, completion: nil)
    }
}


// MARK: - SPAppleAuthManagerContextProvider
//
@available(iOS 13.0, *)
extension SPOnboardingViewController: SPAppleAuthManagerContextProvider {

    func presentationAnchor(for controller: SPAppleAuthManager) -> UIWindow {
        return view.window!
    }
}


// MARK: - Private Types
//
private struct OnboardingStrings {
    static let brandText            = NSLocalizedString("Simplenote", comment: "Our mighty brand!")
    static let signupText           = NSLocalizedString("Create an account", comment: "Signup Action")
    static let loginText            = NSLocalizedString("Log In", comment: "Login Action")
    static let headerText           = NSLocalizedString("The simplest way to keep notes.", comment: "Onboarding Header Text")
    static let loginWithEmailText   = NSLocalizedString("Log in with email", comment: "Presents the regular Email signin flow")
    static let loginWithDotcomText  = NSLocalizedString("Log in with WordPress.com", comment: "Allows the user to SignIn using their WPCOM Account")
}


private struct SignInError {
    static let title                = NSLocalizedString("Couldn't Sign In", comment: "Alert dialog title displayed on sign in error")
    static let genericErrorText     = NSLocalizedString("An error was encountered while signing in.", comment: "Sign in error message")
    static let acceptButtonText     = NSLocalizedString("OK", comment: "Dismisses an AlertController")
}
