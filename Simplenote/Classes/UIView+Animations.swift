import Foundation
import UIKit


// MARK: - UIView's Animation Methods
//
extension UIView {

    /// Animates a visibility switch, when applicable.
    /// - Note: We're animating the Alpha property, and effectively switching the `isHidden` property onCompletion.
    ///
    func animateVisibility(isHidden: Bool, duration: TimeInterval = UIKitConstants.animationQuickDuration) {
        guard self.isHidden != isHidden else {
            return
        }

        let animationAlpha = isHidden ? UIKitConstants.alpha0_0 : UIKitConstants.alpha1_0

        UIView.animate(withDuration: duration) {
            self.isHidden = isHidden
            self.alpha = animationAlpha
        }
    }
}
