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

    /// Initializes a new UIColor instance with a given Dark / Light colors.
    ///
    static func color(lightColor: @autoclosure @escaping () -> UIColor,
                      darkColor: @autoclosure @escaping () -> UIColor) -> UIColor {
        guard #available(iOS 13.0, *) else {
            let targetColor = SPUserInterface.isDark ? darkColor : lightColor
            return targetColor()
        }

        return UIColor(dynamicProvider: { traits in
            let targetColor = traits.userInterfaceStyle == .dark ? darkColor : lightColor
            return targetColor()
        })
    }
}

// MARK: - Private
//
private extension UIColor {

    static var theme: VSTheme {
        return VSThemeManager.shared().theme()
    }
}
