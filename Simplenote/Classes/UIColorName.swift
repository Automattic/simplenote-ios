import Foundation
import UIKit


// MARK: - Simplenote Named Colors
//
@objc
enum UIColorName: Int, CaseIterable {
    case actionViewButtonDisabledColor
    case actionViewStatusFontColor
}


// MARK: - Public Methods
//
extension UIColorName {

    /// Returns the matching Legacy VSTheme Key
    ///
    var legacyColorKey: ThemeColorKey {
        switch self {
        case .actionViewButtonDisabledColor:
            return .actionViewButtonDisabledColor
        case .actionViewStatusFontColor:
            return .actionViewStatusFontColor
        }
    }
}
