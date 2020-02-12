import Foundation
import UIKit


// MARK: - UIView's Animation Methods
//
extension UIView {

    /// Animates a visibility switch, when applicable
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
