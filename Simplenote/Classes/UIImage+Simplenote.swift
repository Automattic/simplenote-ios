import Foundation
import UIKit


// MARK: - Simplenote's UIImage Static Methods
//
extension UIImage {

    /// Returns the UIColor instance matching a given UIColorName. If any
    ///
    @objc
    static func image(name: UIImageName) -> UIImage? {
        // Note:
        // We must differentiate between *Filename* and *rawValue* since, internally, the legacy VSTheme tooling maps
        // the "rawValue" into the actual filename, based on the current theme.
        if #available(iOS 13.0, *) {
            return UIImage(named: name.legacyImageKey.filename)
        }

        return theme.image(forKey: name.legacyImageKey.rawValue)
    }
}


// MARK: - Private
//
private extension UIImage {

    static var theme: VSTheme {
        return VSThemeManager.shared().theme()
    }
}
