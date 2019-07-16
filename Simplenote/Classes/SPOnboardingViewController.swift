import Foundation
import UIKit


// MARK: - SPOnboardingViewController
//
class SPOnboardingViewController: UIViewController, SPAuthenticationInterface {

    ///
    ///
    var authenticator: SPAuthenticator?

    ///
    ///
    var optional = false

    ///
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
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
        let backButton = UIBarButtonItem(title: String(),
                                         style: .plain,
                                         target: nil,
                                         action: nil)

        navigationItem.backBarButtonItem = backButton
        navigationController?.isNavigationBarHidden = true
    }
}
