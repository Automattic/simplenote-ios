import Foundation
import UIKit


// MARK: - SPSignupViewController
//
class SPSignupViewController: UIViewController {

    /// Simperium's Authenticator Instance
    ///
    let authenticator: SPAuthenticator

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
}


// MARK: - Private
//
private extension SPSignupViewController {

    func setupNavigationController() {
        title = NSLocalizedString("Sign Up", comment: "Sign Up Title")
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.applySimplenoteLightStyle()
    }
}
