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
}
