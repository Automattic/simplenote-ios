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
    func attach(child: UIViewController) {
        view.addSubview(child.view)
        addChild(child)
    }

    /// Detaches the receiver from its parent
    ///
    func detach() {
        view.removeFromSuperview()
        removeFromParent()
    }
}
