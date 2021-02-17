import Foundation
import UIKit


// MARK: - UIAlertController's Simplenote Methods
//
extension UIViewController {
    /// View to use to attach another view controller
    ///
    enum AttachmentView {
        case below(UIView)
        case into(UIView)
    }

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
    func attach(to parent: UIViewController, attachmentView: AttachmentView? = nil, animated: Bool = false) {
        guard self.parent != parent else {
            return
        }
        detach()

        parent.addChild(self)

        let attachmentView = attachmentView ?? .into(parent.view)
        switch attachmentView {
        case .below(let siblingView):
            siblingView.superview?.insertSubview(view, belowSubview: siblingView)
            siblingView.superview?.pinSubviewToAllEdges(view)
        case .into(let containerView):
            containerView.addFillingSubview(view)
        }

        let taskBlock = {
            self.didMove(toParent: parent)
        }

        if animated {
            view.fadeIn { _ in
                taskBlock()
            }
        } else {
            taskBlock()
        }
    }

    /// Detaches the receiver from its parent
    ///
    func detach(animated: Bool = false) {
        guard parent != nil else {
            return
        }

        let taskBlock = {
            self.view.removeFromSuperview()
            self.removeFromParent()
        }

        willMove(toParent: nil)
        if animated {
            view.fadeOut { _ in
                taskBlock()
            }
        } else {
            taskBlock()
        }
    }
}
