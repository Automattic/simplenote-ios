import Foundation
import UIKit


// MARK: - Simplenote Named Colors
//
@objc
enum UIColorName: Int, CaseIterable {
    case destructiveActionColor
    case secondaryActionColor
    case tertiaryActionColor
    case actionSheetBackgroundColor
    case actionSheetButtonFontColor
    case actionSheetButtonBackgroundHighlightColor
    case actionSheetDividerColor
    case actionSheetFontColor
    case actionViewButtonDisabledColor
    case actionViewStatusFontColor
    case actionViewToggleTintColor
    case backgroundColor
    case barTintColor
    case collaboratorCellPrimaryLabelFontColor
    case collaboratorCellSecondaryLabelFontColor
    case collaboratorTextFieldTextColor
    case collaboratorTextFieldPlaceholderTextColor
    case emptyListViewFontColor
    case horizontalPickerBorderColor
    case horizontalPickerTitleFontColor
    case lockBackgroundColor
    case lockTextColor
    case navigationBarTitleFontColor
    case noteBodyFontPreviewColor
    case noteCellBackgroundSelectionColor
    case noteHeadlineFontColor
    case searchBarImageColor
    case searchBarFontColor
    case searchHighlightFontColor
    case switchTintColor
    case switchOnTintColor
    case tableViewBackgroundColor
    case tableViewCellBackgroundHighlightColor
    case tableViewDetailTextLabelColor
    case tableViewSeparatorColor
    case tableViewTextLabelColor
    case tagListFontColor
    case tagListFontHighlightColor
    case tagListHighlightBackgroundColor
    case tagListSeparatorColor
    case tagViewAutoCompleteFontColor
    case tagViewFontColor
    case tagViewFontColorSelected
    case tagViewFontHighlightedColor
    case tagViewPlaceholderColor
    case tagViewDeletionBackgroundColor
    case tagViewDeletionBackgroundBorderColor
    case textColor
    case tintColor
    case versionPickerDateFontColor
}


// MARK: - Public Methods
//
extension UIColorName {

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
        case .actionSheetBackgroundColor:
            return .actionSheetBackgroundColor
        case .actionSheetButtonFontColor:
            return .actionSheetButtonFontColor
        case .actionSheetButtonBackgroundHighlightColor:
            return .actionSheetButtonBackgroundHighlightColor
        case .actionSheetDividerColor:
            return .actionSheetDividerColor
        case .actionSheetFontColor:
            return .actionSheetFontColor
        case .actionViewButtonDisabledColor:
            return .actionViewButtonDisabledColor
        case .actionViewStatusFontColor:
            return .actionViewStatusFontColor
        case .actionViewToggleTintColor:
            return .actionViewToggleTintColor
        case .backgroundColor:
            return .backgroundColor
        case .barTintColor:
            return .barTintColor
        case .collaboratorCellPrimaryLabelFontColor:
            return .collaboratorCellPrimaryLabelFontColor
        case .collaboratorCellSecondaryLabelFontColor:
            return .collaboratorCellSecondaryLabelFontColor
        case .collaboratorTextFieldTextColor:
            return .collaboratorTextFieldTextColor
        case .collaboratorTextFieldPlaceholderTextColor:
            return .collaboratorTextFieldPlaceholderTextColor
        case .emptyListViewFontColor:
            return .emptyListViewFontColor
        case .horizontalPickerBorderColor:
            return .horizontalPickerBorderColor
        case .horizontalPickerTitleFontColor:
            return .horizontalPickerTitleFontColor
        case .lockBackgroundColor:
            return .lockBackgroundColor
        case .lockTextColor:
            return .lockTextColor
        case .navigationBarTitleFontColor:
            return .navigationBarTitleFontColor
        case .noteBodyFontPreviewColor:
            return .noteBodyFontPreviewColor
        case .noteCellBackgroundSelectionColor:
            return .noteCellBackgroundSelectionColor
        case .noteHeadlineFontColor:
            return .noteHeadlineFontColor
        case .searchBarImageColor:
            return .searchBarImageColor
        case .searchBarFontColor:
            return .searchBarFontColor
        case .searchHighlightFontColor:
            return .searchHighlightFontColor
        case .switchTintColor:
            return .switchTintColor
        case .switchOnTintColor:
            return .switchOnTintColor
        case .tableViewBackgroundColor:
            return .tableViewBackgroundColor
        case .tableViewCellBackgroundHighlightColor:
            return .tableViewCellBackgroundHighlightColor
        case .tableViewDetailTextLabelColor:
            return .tableViewDetailTextLabelColor
        case .tableViewSeparatorColor:
            return .tableViewSeparatorColor
        case .tableViewTextLabelColor:
            return .tableViewTextLabelColor
        case .tagListFontColor:
            return .tagListFontColor
        case .tagListFontHighlightColor:
            return .tagListFontHighlightColor
        case .tagListHighlightBackgroundColor:
            return .tagListHighlightBackgroundColor
        case .tagListSeparatorColor:
            return .tagListSeparatorColor
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
        case .tagViewDeletionBackgroundColor:
            return .tagViewDeletionBackgroundColor
        case .tagViewDeletionBackgroundBorderColor:
            return .tagViewDeletionBackgroundBorderColor
        case .textColor:
            return .textColor
        case .tintColor:
            return .tintColor
        case .versionPickerDateFontColor:
            return .versionPickerDateFontColor
        }
    }
}
