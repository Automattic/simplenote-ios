import Foundation
import UIKit


// MARK: - UITableViewHeaderFooterView Methods
//
extension UITableViewHeaderFooterView {

    /// Returns the reuseIdentifier: By (our) convention, this will always just match the cllassname.
    ///
    @objc
    static var reuseIdentifier: String {
        return classNameWithoutNamespaces
    }
}
