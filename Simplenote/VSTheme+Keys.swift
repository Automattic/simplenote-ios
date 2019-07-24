import Foundation


// MARK: - ThemeKey represents all of the available Keys for the current theme.
//
enum ThemeKey: String {
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

    case noteBodyLineHeightPercentage
}


// MARK: - Public Methods
//
extension VSTheme {

    /// Returns the color associated to a given Key
    ///
    func color(forKey key: ThemeKey) -> UIColor? {
        return color(forKey: key.rawValue)
    }

    /// Returns the Float Value associated to a given ThemeKey
    ///
    func float(forKey key: ThemeKey) -> CGFloat {
        return float(forKey: key.rawValue)
    }
}
