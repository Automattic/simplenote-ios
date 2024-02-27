import Foundation

// MARK: - UIKeyboardAppearance
//
extension UIKeyboardAppearance {

    /// Returns the Keyboard Appearance matching the current Style
    ///
    static var simplenoteKeyboardAppearance: UIKeyboardAppearance {
        SPUserInterface.isDark ? .dark : .default
    }
}
