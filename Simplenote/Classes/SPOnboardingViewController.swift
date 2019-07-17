import Foundation
import UIKit


// MARK: - SPOnboardingViewController
//
class SPOnboardingViewController: UIViewController, SPAuthenticationInterface {

    /// Our awesome brand
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


    // MARK: - Overridden Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        setupActionButtons()
        setupLabels()
    }

    @IBAction func signupWasPressed() {
        guard let authenticator = authenticator else {
            fatalError()
        }

        let viewController = SPSignupViewController(authenticator: authenticator)
        navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func loginWasPressed() {
        guard let authenticator = authenticator else {
            fatalError()
        }

        let viewController = SPLoginViewController(authenticator: authenticator)
        navigationController?.pushViewController(viewController, animated: true)
    }
}


// MARK: - Private
//
private extension SPOnboardingViewController {

    func setupNavigationController() {
        // Don't show the previous VC's title in the next-view's back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: String(), style: .plain, target: nil, action: nil)
        navigationController?.isNavigationBarHidden = true
    }

    func setupActionButtons() {
        let signupText = NSLocalizedString("Create an account", comment: "Signup Action")
        signUpButton.setTitle(signupText, for: .normal)
        signUpButton.setTitleColor(.white, for: .normal)
        signUpButton.backgroundColor = .simplenoteMidBlue()

        let loginText = NSLocalizedString("Log In", comment: "Login Action")
        loginButton.setTitle(loginText, for: .normal)
        loginButton.setTitleColor(.simplenoteLightNavy(), for: .normal)
    }

    func setupLabels() {
        simplenoteLabel.textColor = .simplenoteAlmostBlack()
        headerLabel.textColor = .simplenoteAlmostBlack()
    }
}
