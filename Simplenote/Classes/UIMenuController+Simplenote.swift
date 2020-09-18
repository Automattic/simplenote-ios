import Foundation
import UIKit


// MARK: - UIMenuController + Simplenote
//
extension UIMenuController {

    /// Dismisses the receiver if it was previously visible
    ///
    @objc
    func dismissIfNeeded() {
        guard isMenuVisible else {
            return
        }

        setMenuVisible(false, animated: true)
    }

    /// Displays the receiver from the specified coordinates
    ///
    @objc(displayFromTargetRect:inView:)
    func display(from targetRect: CGRect, in view: UIView) {
        setTargetRect(targetRect, in: view)
        setMenuVisible(true, animated: true)
    }
}
