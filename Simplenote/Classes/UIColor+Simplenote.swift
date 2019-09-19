import Foundation
import UIKit


// MARK: - Simplenote UIColor(s)
//
extension UIColor {

    /// Returns the UIColor instance matching a given UIColorName. If any
    ///
    @objc
    static func color(name: UIColorName) -> UIColor? {
        if #available(iOS 13.0, *) {
            return UIColor(named: name.legacyColorKey.rawValue)
        }

        return theme.color(forKey: name.legacyColorKey.rawValue)
    }
}

// MARK: - Private
//
private extension UIColor {

    static var theme: VSTheme {
        return VSThemeManager.shared().theme()
    }
}
