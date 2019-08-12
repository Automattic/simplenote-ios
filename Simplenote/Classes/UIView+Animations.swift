import Foundation
import UIKit


// MARK: - UIView's Animation Methods
//
extension UIView {

    /// Animates a visibility switch, when applicable
    ///
    func animateVisibility(isHidden: Bool, duration: TimeInterval = 0.3) {
        guard self.isHidden != isHidden else {
            return
        }

        UIView.animate(withDuration: duration) {
            self.isHidden = isHidden
        }
    }
}
