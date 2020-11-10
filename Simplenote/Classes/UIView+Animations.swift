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

    /// Performs a FadeIn animation
    ///
    func fadeIn(onCompletion: ((Bool) -> Void)? = nil) {
        alpha = .zero

        UIView.animate(withDuration: UIKitConstants.animationQuickDuration, animations: {
            self.alpha = UIKitConstants.alpha1_0
        }, completion: onCompletion)
    }

    /// Performs a FadeOut animation
    ///
    func fadeOut(onCompletion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: UIKitConstants.animationQuickDuration, animations: {
            self.alpha = UIKitConstants.alpha0_0
        }, completion: onCompletion)
    }
}
