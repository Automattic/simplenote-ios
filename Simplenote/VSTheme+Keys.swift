import Foundation


// MARK: - ThemeKey represents all of the available Keys for the current theme.
//
enum ThemeKey: String {
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
    case lockTextColor
    case lockBackgroundColor
    case navigationBarTitleFontColor
    case noteBodyFontPreviewColor
    case noteHeadlineFontColor
    case searchBarImageColor
    case searchHighlightFontColor
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

    /// TODO: Nuke VSTheme *entirely* and implement a simpler way to access UI Constants
    ///
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
