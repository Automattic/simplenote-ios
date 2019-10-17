import Foundation
import UIKit


// MARK: - Simplenote Named Images
//
@objc
enum UIImageName: Int, CaseIterable {
    case add
    case allNotes
    case checklist
    case checkmarkChecked
    case checkmarkUnchecked
    case chevronLeft
    case chevronRight
    case collaborate
    case hideKeyboard
    case history
    case info
    case menu
    case newNote
    case pin
    case settings
    case share
    case shared
    case tag
    case trash
    case navigationBarBackground
    case navigationBarBackgroundPrompt
    case onePassword
    case tagViewDeletion
    case visibilityOn
    case visibilityOff
}


// MARK: - Public Methods
//
extension UIImageName {

    /// Light Asset Filename
    ///
    var lightAssetFilename: String {
        switch self {
        case .add:
            return "icon_add"
        case .allNotes:
            return "icon_allnotes"
        case .checklist:
            return "icon_checklist"
        case .checkmarkChecked:
            return "icon_checkmark_checked"
        case .checkmarkUnchecked:
            return "icon_checkmark_unchecked"
        case .chevronLeft:
            return "icon_chevron_left"
        case .chevronRight:
            return "icon_chevron_right"
        case .collaborate:
            return "icon_collaborate"
        case .hideKeyboard:
            return "icon_hide_keyboard"
        case .history:
            return "icon_history"
        case .info:
            return "icon_info"
        case .menu:
            return "icon_menu"
        case .newNote:
            return "icon_new_note"
        case .pin:
            return "icon_pin"
        case .settings:
            return "icon_settings"
        case .share:
            return "icon_share"
        case .shared:
            return "icon_shared"
        case .tag:
            return "icon_tag"
        case .trash:
            return "icon_trash"
        case .navigationBarBackground:
            return "navigation_bar_background"
        case .navigationBarBackgroundPrompt:
            return "navigation_bar_background_prompt"
        case .onePassword:
            return "icon_onepassword"
        case .tagViewDeletion:
            return "button_delete_small"
        case .visibilityOn:
            return "icon_visibility_on"
        case .visibilityOff:
            return "icon_visibility_off"
        }
    }

    /// Dark Asset Filename
    ///
    var darkAssetFilename: String? {
        switch self {
        case .navigationBarBackground:
            return "navigation_bar_background_dark"
        case .navigationBarBackgroundPrompt:
            return "navigation_bar_background_prompt_dark"
        case .tagViewDeletion:
            return "button_delete_small_dark"
        default:
            return nil
        }
    }
}
