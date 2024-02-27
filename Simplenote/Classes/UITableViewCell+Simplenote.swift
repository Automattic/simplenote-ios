import Foundation
import UIKit

/// UITableViewCell Helpers
///
extension UITableViewCell {
    enum SeparatorWidth {
        case full
        case standard
    }

    /// Returns a reuseIdentifier that matches the receiver's classname (non namespaced).
    ///
    @objc
    class var reuseIdentifier: String {
        return classNameWithoutNamespaces
    }

    /// Adjust width of a separator
    ///
    func adjustSeparatorWidth(width: SeparatorWidth) {
        var separatorInset = self.separatorInset
        separatorInset.left = width == .full ? 0 : contentView.layoutMargins.left
        separatorInset.right = 0
        self.separatorInset = separatorInset
    }
}
