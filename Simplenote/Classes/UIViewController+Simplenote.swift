import Foundation
import UIKit


// MARK: - UIAlertController's Simplenote Methods
//
extension UIViewController {

    /// Presents the receiver from the RootViewController's leaf
    ///
    @objc
    func presentFromRootViewController() {
        // Note:
        // This method is required because the presenter ViewController must be visible, and we've got several
        // flows in which the VC that triggers the alert, might not be visible anymore.
        //
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            print("Error loading the rootViewController")
            return
        }

        var leafViewController = rootViewController
        while leafViewController.presentedViewController != nil {
            leafViewController = leafViewController.presentedViewController!
        }

        leafViewController.present(self, animated: true, completion: nil)
    }

    /// Attaches a children ViewController (if needed)
    ///
    func attachWithAnimation(to parent: UIViewController) {
        parent.view.addSubview(view)
        parent.addChild(self)
        view.fadeIn()
    }

    /// Detaches the receiver from its parent
    ///
    func detachWithAnimation() {
        view.fadeOut { _ in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
}
