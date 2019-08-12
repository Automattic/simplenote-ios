import Foundation
import UIKit


// MARK: - Simplenote Named Colors
//
@objc
enum UIColorName: Int {
    case destructiveActionColor
    case secondaryActionColor
    case tertiaryActionColor
}


// MARK: - Public Methods
//
extension UIColorName {

    /// Returns the matching Asset Catalog  Name
    ///
    var assetCatalogName: String {
        switch self {
        default:
            return ""
        }
    }

    /// Returns the matching Legacy VSTheme Key
    ///
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
