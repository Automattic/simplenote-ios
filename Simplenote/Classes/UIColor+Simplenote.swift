import Foundation
import UIKit


// MARK: - Simplenote UIColor(s)
//
extension UIColor {

    /// Returns the UIColor instance matching a given UIColorName. If any
    ///
    @objc
    static func color(name: UIColorName) -> UIColor? {
// TODO: Unlock when:
//  1.  The Colors are properly populated
//  2.  The Dark Mode switch is enhanced to deal with Traits
//        if #available(iOS 13.0, *) {
//            return UIColor(named: name.assetCatalogName)
//        }

        return theme.color(forKey: name.legacyThemeKey)
    }
}


// MARK: - Private
//
private extension UIColor {

    static var theme: VSTheme {
        return VSThemeManager.shared().theme()
    }
}
