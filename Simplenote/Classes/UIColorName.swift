import Foundation
import UIKit


// MARK: - Simplenote Named Colors
//
@objc
enum UIColorName: Int, CaseIterable {
    case actionSheetButtonFontColor
    case actionSheetButtonBackgroundHighlightColor
    case actionViewButtonDisabledColor
    case actionViewStatusFontColor
    case tableViewDetailTextLabelColor
}


// MARK: - Public Methods
//
extension UIColorName {

    /// Returns the matching Legacy VSTheme Key
    ///
    var legacyColorKey: ThemeColorKey {
        switch self {
        case .actionSheetButtonFontColor:
            return .actionSheetButtonFontColor
        case .actionSheetButtonBackgroundHighlightColor:
            return .actionSheetButtonBackgroundHighlightColor
        case .actionViewButtonDisabledColor:
            return .actionViewButtonDisabledColor
        case .actionViewStatusFontColor:
            return .actionViewStatusFontColor
        case .tableViewDetailTextLabelColor:
            return .tableViewDetailTextLabelColor
        }
    }
}
