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

    /// Indicates if the receiver is Regular x Regular (Vertically and Horizontally)
    ///
    @objc
    func isRegularByRegular() -> Bool {
        return traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular
    }
}
