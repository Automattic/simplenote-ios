import Foundation
import UIKit


// MARK: - UIViewController Helpers
//
extension UIViewController {

    /// YES! You guessed right! By default, the restorationIdentifier will be the class name 🎯
    ///
    class var defaultRestorationIdentifier: String {
        classNameWithoutNamespaces
    }

    /// Returns the default nibName: Matches the classname (expressed as a String!)
    ///
    class var nibName: String {
        return classNameWithoutNamespaces
    }
}
