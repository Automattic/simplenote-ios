import Foundation
import UIKit


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
