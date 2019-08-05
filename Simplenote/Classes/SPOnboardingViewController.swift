import Foundation
import UIKit


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


    // MARK: - Overridden Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupNavigationController()
        setupLabels()
        setupActionButtons()
    }

    @IBAction func signupWasPressed() {
        presentAuthenticationInterface(mode: .signup)
    }

    @IBAction func loginWasPressed() {
        presentAuthenticationInterface(mode: .login)
    }
}


// MARK: - Private
//
private extension SPOnboardingViewController {

    func setupNavigationItem() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: String(), style: .plain, target: nil, action: nil)
    }

    func setupNavigationController() {
        navigationController?.isNavigationBarHidden = true
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

    func presentAuthenticationInterface(mode: AuthenticationMode) {
        guard let simperiumAuthenticator = authenticator else {
            fatalError()
        }

        let viewController = SPAuthViewController(simperiumAuthenticator: simperiumAuthenticator, mode: mode)
        navigationController?.pushViewController(viewController, animated: true)
    }
}


// MARK: - Private Types
//
private struct OnboardingStrings {
    static let brandText    = NSLocalizedString("Simplenote", comment: "Our mighty brand!")
    static let signupText   = NSLocalizedString("Create an account", comment: "Signup Action")
    static let loginText    = NSLocalizedString("Log In", comment: "Login Action")
    static let headerText   = NSLocalizedString("The simplest way to keep notes.", comment: "Onboarding Header Text")
}
