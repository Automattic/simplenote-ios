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
    case backgroundColor
    case collaboratorTextColor
    case dividerColor
    case emptyListViewFontColor
    case horizontalPickerBorderColor
    case horizontalPickerTitleFontColor
    case lightBlueColor
    case noteBodyFontPreviewColor
    case noteHeadlineFontColor
    case tableViewBackgroundColor
    case tableViewDetailTextLabelColor
    case tagViewAutoCompleteFontColor
    case tagViewFontColor
    case tagViewFontColorSelected
    case tagViewFontHighlightedColor
    case tagViewPlaceholderColor
    case tagViewDeletionBackgroundBorderColor
    case textColor
    case tintColor
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
        case .backgroundColor:
            return .backgroundColor
        case .collaboratorTextColor:
            return .collaboratorTextColor
        case .dividerColor:
            return .dividerColor
        case .emptyListViewFontColor:
            return .emptyListViewFontColor
        case .horizontalPickerBorderColor:
            return .horizontalPickerBorderColor
        case .horizontalPickerTitleFontColor:
            return .horizontalPickerTitleFontColor
        case .lightBlueColor:
            return .lightBlueColor
        case .noteBodyFontPreviewColor:
            return .noteBodyFontPreviewColor
        case .noteHeadlineFontColor:
            return .noteHeadlineFontColor
        case .tableViewBackgroundColor:
            return .tableViewBackgroundColor
        case .tableViewDetailTextLabelColor:
            return .tableViewDetailTextLabelColor
        case .tagViewAutoCompleteFontColor:
            return .tagViewAutoCompleteFontColor
        case .tagViewFontColor:
            return .tagViewFontColor
        case .tagViewFontColorSelected:
            return .tagViewFontColorSelected
        case .tagViewFontHighlightedColor:
            return .tagViewFontHighlightedColor
        case .tagViewPlaceholderColor:
            return .tagViewPlaceholderColor
        case .tagViewDeletionBackgroundBorderColor:
            return .tagViewDeletionBackgroundBorderColor
        case .textColor:
            return .textColor
        case .tintColor:
            return .tintColor
        }
    }
}
