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

    /// Configures the receiver to be presented as a popover from the specified Source View
    ///
    func configureAsPopover(sourceView: UIView) {
        modalPresentationStyle = .popover

        guard let presentationController = popoverPresentationController else {
            assertionFailure()
            return
        }

        presentationController.sourceRect = sourceView.bounds
        presentationController.sourceView = sourceView
        presentationController.backgroundColor = .simplenoteNavigationBarModalBackgroundColor
    }
}
