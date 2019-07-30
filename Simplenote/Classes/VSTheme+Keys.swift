import Foundation


// MARK: - ThemeColorKey represents all of the available Color Keys
//
enum ThemeColorKey: String {
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
}


// MARK: - ThemeImageKey represents all of the available Image Keys
//
enum ThemeImageKey: String {
    case backImage
    case pinImage
    case sharedImage
    case navigationBarShadowImage
    case navigationBarBackgroundImage
    case navigationBarBackgroundPromptImage
    case searchBarBackgroundImage
    case tagViewDeletionImage
}


extension ThemeImageKey {

    var filename: String {
        switch self {
        case .backImage:
            return "back_chevron"
        case .pinImage:
            return "icon_pin"
        case .sharedImage:
            return "icon_shared"
        case .navigationBarShadowImage:
            return "navigation_bar_shadow"
        case .navigationBarBackgroundImage:
            return "navigation_bar_background"
        case .navigationBarBackgroundPromptImage:
            return "navigation_bar_background_prompt"
        case .searchBarBackgroundImage:
            return "searchbar_background"
        case .tagViewDeletionImage:
            return "button_delete_small"
        }
    }
}
