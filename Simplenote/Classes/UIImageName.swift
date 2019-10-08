import Foundation
import UIKit


// MARK: - Simplenote Named Images
//
@objc
enum UIImageName: Int, CaseIterable {
    case addImage
    case allNotesImage
    case checklistImage
    case checkmarkCheckedImage
    case checkmarkUncheckedImage
    case chevronLeftImage
    case chevronRightImage
    case collaborateImage
    case hideKeyboardImage
    case historyImage
    case infoImage
    case menuImage
    case newNoteImage
    case pinImage
    case settingsImage
    case shareImage
    case sharedImage
    case trashImage
    case navigationBarBackgroundImage
    case navigationBarBackgroundPromptImage
    case onePasswordImage
    case tagViewDeletionImage
    case trashIcon
    case visibilityOnImage
    case visibilityOffImage
}


// MARK: - Public Methods
//
extension UIImageName {

    /// Light Asset Filename
    ///
    var lightAssetFilename: String {
        switch self {
        case .addImage:
            return "icon_add"
        case .allNotesImage:
            return "icon_allnotes"
        case .checklistImage:
            return "icon_checklist"
        case .checkmarkCheckedImage:
            return "icon_checkmark_checked"
        case .checkmarkUncheckedImage:
            return "icon_checkmark_unchecked"
        case .chevronLeftImage:
            return "icon_chevron_left"
        case .chevronRightImage:
            return "icon_chevron_right"
        case .collaborateImage:
            return "icon_collaborate"
        case .hideKeyboardImage:
            return "icon_hide_keyboard"
        case .historyImage:
            return "icon_history"
        case .infoImage:
            return "icon_info"
        case .menuImage:
            return "icon_menu"
        case .newNoteImage:
            return "icon_new_note"
        case .pinImage:
            return "icon_pin"
        case .settingsImage:
            return "icon_settings"
        case .shareImage:
            return "icon_share"
        case .sharedImage:
            return "icon_shared"
        case .trashImage:
            return "icon_trash"
        case .navigationBarBackgroundImage:
            return "navigation_bar_background"
        case .navigationBarBackgroundPromptImage:
            return "navigation_bar_background_prompt"
        case .onePasswordImage:
            return "icon_onepassword"
        case .tagViewDeletionImage:
            return "button_delete_small"
        case .trashIcon:
            return "icon_trash"
        case .visibilityOnImage:
            return "icon_visibility_on"
        case .visibilityOffImage:
            return "icon_visibility_off"
        }
    }

    /// Dark Asset Filename
    ///
    var darkAssetFilename: String? {
        switch self {
        case .navigationBarBackgroundImage:
            return "navigation_bar_background_dark"
        case .navigationBarBackgroundPromptImage:
            return "navigation_bar_background_prompt_dark"
        case .tagViewDeletionImage:
            return "button_delete_small_dark"
        default:
            return nil
        }
    }
}
