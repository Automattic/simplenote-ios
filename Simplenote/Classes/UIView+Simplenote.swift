import Foundation
import UIKit


// MARK: - UIView's Simplenote Methods
//
extension UIView {

    /// Indicates if the receiver has the horizontal compact trait
    ///
    @objc
    func isHorizontallyCompact() -> Bool {
        return traitCollection.horizontalSizeClass == .compact
    }
}
