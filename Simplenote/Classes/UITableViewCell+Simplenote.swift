import Foundation
import UIKit


/// UITableViewCell Helpers
///
extension UITableViewCell {

    /// Returns a reuseIdentifier that matches the receiver's classname (non namespaced).
    ///
    @objc
    class var reuseIdentifier: String {
        return classNameWithoutNamespaces
    }
}
