import Foundation
import UIKit


// MARK: - Simplenote Named Colors
//
@objc
enum UIColorName: Int, CaseIterable {
    case destructiveActionColor
    case secondaryActionColor
    case tertiaryActionColor
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
    case lockBackgroundColor
    case lockTextColor
    case navigationBarTitleFontColor
    case noteBodyFontPreviewColor
    case noteHeadlineFontColor
    case searchBarImageColor
    case searchHighlightFontColor
    case simplenoteAlmostBlack
    case simplenoteDeepSeaBlue
    case simplenoteGray10
    case simplenoteGunmetal
    case simplenoteLightNavy
    case simplenoteLightPink
    case simplenoteLipstick
    case simplenoteMidBlue
    case simplenotePalePurple
    case simplenoteSlateGrey
    case switchTintColor
    case switchOnTintColor
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
        case .destructiveActionColor:
            return .destructiveActionColor
        case .secondaryActionColor:
            return .secondaryActionColor
        case .tertiaryActionColor:
            return .tertiaryActionColor
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
        case .lockBackgroundColor:
            return .lockBackgroundColor
        case .lockTextColor:
            return .lockTextColor
        case .navigationBarTitleFontColor:
            return .navigationBarTitleFontColor
        case .noteBodyFontPreviewColor:
            return .noteBodyFontPreviewColor
        case .noteHeadlineFontColor:
            return .noteHeadlineFontColor
        case .searchBarImageColor:
            return .searchBarImageColor
        case .searchHighlightFontColor:
            return .searchHighlightFontColor
        case .simplenoteAlmostBlack:
            return .simplenoteAlmostBlack
        case .simplenoteDeepSeaBlue:
            return .simplenoteDeepSeaBlue
        case .simplenoteGray10:
            return .simplenoteGray10
        case .simplenoteGunmetal:
            return .simplenoteGunmetal
        case .simplenoteLightNavy:
            return .simplenoteLightNavy
        case .simplenoteLightPink:
            return .simplenoteLightPink
        case .simplenoteLipstick:
            return .simplenoteLipstick
        case .simplenoteMidBlue:
            return .simplenoteMidBlue
        case .simplenotePalePurple:
            return .simplenotePalePurple
        case .simplenoteSlateGrey:
            return .simplenoteSlateGrey
        case .switchTintColor:
            return .switchTintColor
        case .switchOnTintColor:
            return .switchOnTintColor
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
