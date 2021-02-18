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
        guard let rootViewController = UIApplication.shared.delegate?.window??.rootViewController else {
            print("Error loading the rootViewController")
            return
        }

        var leafViewController = rootViewController
        while leafViewController.presentedViewController != nil {
            leafViewController = leafViewController.presentedViewController!
        }

        leafViewController.present(self, animated: true, completion: nil)
    }

    /// Attaches a children ViewController (if needed) below the specified sibling view
    ///
    func attachWithAnimation(to parent: UIViewController, below siblingView: UIView? = nil) {
        parent.addChild(self)
        if let siblingView = siblingView {
            parent.view.insertSubview(view, belowSubview: siblingView)
        } else {
            parent.view.addSubview(view)
        }
        parent.view.pinSubviewToAllEdges(view)
        view.fadeIn()
        didMove(toParent: parent)
    }

    /// Detaches the receiver from its parent
    ///
    func detachWithAnimation() {
        willMove(toParent: nil)
        view.fadeOut { _ in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
}
