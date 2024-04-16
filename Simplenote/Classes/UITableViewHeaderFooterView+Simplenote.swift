import Foundation
import UIKit

/// UITableViewHeaderFooterView Helpers
///
extension UITableViewHeaderFooterView {

    /// Returns a reuseIdentifier that matches the receiver's classname (non namespaced).
    ///
    @objc
    class var reuseIdentifier: String {
        return classNameWithoutNamespaces
    }
}
