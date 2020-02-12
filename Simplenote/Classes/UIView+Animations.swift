import Foundation
import UIKit


// MARK: - UIView's Animation Methods
//
extension UIView {

    /// Animates a visibility switch, when applicable.
    /// - Note: We're animating the Alpha property, and effectively switching the `isHidden` property onCompletion.
    ///         Whenever the animation is thru, we'll also restore Alpha to full (1.0).
    ///
    func animateVisibility(isHidden: Bool, duration: TimeInterval = UIKitConstants.animationQuickDuration) {
        guard self.isHidden != isHidden else {
            return
        }

        let animationAlpha = isHidden ? UIKitConstants.alphaZero : UIKitConstants.alphaFull
        let completionAlpha = UIKitConstants.alphaFull

        UIView.animate(withDuration: duration, animations: {
            self.alpha = animationAlpha
        }, completion: { _ in
            self.isHidden = isHidden
            self.alpha = completionAlpha
        })
    }
}
