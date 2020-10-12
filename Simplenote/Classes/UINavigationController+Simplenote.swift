import Foundation


// MARK: - UINavigationController Simplenote API
//
extension UINavigationController {

    /// Returns the first Child ViewController of the specified Type
    ///
    func firstChild<T: UIViewController>(ofType type: T.Type) -> T? {
        for child in children where child is T {
            return child as? T
        }

        return nil
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
