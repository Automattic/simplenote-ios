import Foundation
import UIKit


// MARK: - Simplenote's UIImage Static Methods
//
extension UIImage {

    /// Returns the UIColor instance matching a given UIColorName. If any
    ///
    @objc
    static func image(name: UIImageName) -> UIImage? {
        if #available(iOS 13.0, *) {
            return UIImage(named: name.legacyThemeKey.rawValue)
        }

        return theme.image(forKey: name.legacyThemeKey.rawValue)
    }
}


// MARK: - Private
//
private extension UIImage {

    static var theme: VSTheme {
        return VSThemeManager.shared().theme()
    }
}
