import Foundation
import UIKit


// MARK: - SPSignupViewController
//
class SPSignupViewController: UIViewController {

    ///
    ///
    let authenticator: SPAuthenticator

    ///
    ///
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    ///
    ///
    init(authenticator: SPAuthenticator) {
        self.authenticator = authenticator
        super.init(nibName: nil, bundle: nil)
    }
}
