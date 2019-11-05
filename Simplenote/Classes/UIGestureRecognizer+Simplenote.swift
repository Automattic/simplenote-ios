import Foundation
import UIKit


// MARK: - UIGestureRecognizer Simplenote Methods
//
extension UIGestureRecognizer {

    /// Forgive me: this is the only known way (AFAIK) to force a recognizer to fail. Seen in WWDC 2014 (somewhere), and a better way is yet to be found.
    ///
    @objc
    func fail() {
        isEnabled = false
        isEnabled = true
    }
}
