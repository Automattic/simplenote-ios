import Foundation


// MARK: - ThemeKey represents all of the available Keys for the current theme.
//
enum ThemeKey: String {

    /// Legacy Color Names
    ///
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

    /// Legacy Float Names
    /// TODO: Nuke VSTheme *entirely* and implement a simpler way to access UI Constants
    ///
    case noteBodyLineHeightPercentage

    /// Legacy Image Names
    ///
    case backImage = "back_chevron"
    case pinImage = "icon_pin"
    case sharedImage = "icon_shared"
    case navigationBarShadowImage
    case navigationBarBackgroundImage
    case navigationBarBackgroundPromptImage
    case searchBarBackgroundImage
    case tagViewDeletionImage
}
