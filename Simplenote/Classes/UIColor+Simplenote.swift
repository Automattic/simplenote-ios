import Foundation
import UIKit


// MARK: - Simplenote UIColor(s)
//
@objc
enum UIColorName: Int {
    case destructiveActionColor
    case secondaryActionColor
    case tertiaryActionColor
}

extension UIColorName {
    var assetCatalogName: String {
        switch self {
        default:
            return ""
        }
    }

    var legacyThemeKey: ThemeKey {
        switch self {
        case .destructiveActionColor:
            return .destructiveActionColor
        case .secondaryActionColor:
            return .secondaryActionColor
        case .tertiaryActionColor:
            return .tertiaryActionColor
        }
    }
}

extension UIColor {
    @objc
    static func color(name: UIColorName) -> UIColor? {
        if #available(iOS 13.0, *) {
            return UIColor(named: name.assetCatalogName)
        }

        return theme.color(forKey: name.legacyThemeKey)
    }
}


private extension UIColor {

    static var theme: VSTheme {
        return VSThemeManager.shared().theme()
    }
}
