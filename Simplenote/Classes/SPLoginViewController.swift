import Foundation
import UIKit


// MARK: - SPLoginViewController
//
class SPLoginViewController: UIViewController {

    ///
    ///
    let authenticator: SPAuthenticator

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
private extension SPLoginViewController {

    func setupNavigationController() {
        title = NSLocalizedString("Log In", comment: "Log In Title")
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.applySimplenoteLightStyle()
    }
}
