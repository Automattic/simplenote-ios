import Foundation
import UIKit


// MARK: - Simplenote UIColor(s)
//
extension UIColor {

    @objc
    static func simplenoteAlmostBlack() -> UIColor {
        return UIColor(red: 18.0 / 255.0, green: 23.0 / 255.0, blue: 26.0 / 255.0, alpha: 1.0)
    }

    @objc
    static func simplenoteMidBlue() -> UIColor {
        return UIColor(red: 33.0 / 255.0, green: 112.0 / 255.0, blue: 176.0 / 255.0, alpha: 1.0)
    }

    @objc
    static func simplenoteLightNavy() -> UIColor {
        return UIColor(red: 19.0 / 255.0, green: 93.0 / 255.0, blue: 149.0 / 255.0, alpha: 1.0)
    }

    @objc
    static func simplenoteGreen() -> UIColor {
        return UIColor(red: 29.0/255.0, green: 120.0/255.0, blue: 25.0/255.0, alpha: 1.0)
    }

    @objc
    static func simplenoteRed() -> UIColor {
        return UIColor(red: 202.0/255.0, green: 38.0/255.0, blue: 34.0/255.0, alpha: 1.0)
    }

    @objc
    static func simplenoteYellow() -> UIColor {
        return UIColor(red: 214.0/255.0, green: 176.0/255.0, blue: 44.0/255.0, alpha: 1.0)
    }

    @objc
    static func simplenoteBlue() -> UIColor {
        return UIColor(red: 72.0/255.0, green: 149.0/255.0, blue: 217.0/255.0, alpha: 1.0)
    }

    @objc
    static func simplenoteGray600() -> UIColor {
        return UIColor(red: 111.0/255.0, green: 119.0/255.0, blue: 128.0/255.0, alpha: 1.0)
    }

    @objc
    static func simplenoteGray500() -> UIColor {
        return UIColor(red: 137.0/255.0, green: 145.0/255.0, blue: 153.0/255.0, alpha: 1.0)
    }
}


// MARK: - Dark Mode Helpers
//
extension UIColor {

    @objc
    static func simplenoteDestructiveActionColor() -> UIColor {
        return simplenoteRed()
    }

    @objc
    static func simplenoteSecondaryActionColor() -> UIColor {
        return simplenoteBlue()
    }

    @objc
    static func simplenoteTertiaryActionColor() -> UIColor {
        return isDarkModeEnabled ? simplenoteGray600() : simplenoteGray500()
    }

    private static var isDarkModeEnabled: Bool {
        return VSThemeManager.shared()?.theme()?.bool(forKey: "dark") ?? false
    }
}
