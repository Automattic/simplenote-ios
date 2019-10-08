import Foundation
import UIKit


// MARK: - Simplenote Named Images
//
@objc
enum UIImageName: Int, CaseIterable {
    case addImage
    case checklistImage
    case checkmarkCheckedImage
    case checkmarkUncheckedImage
    case chevronLeftImage
    case chevronRightImage
    case infoImage
    case pinImage
    case sharedImage
    case navigationBarBackgroundImage
    case navigationBarBackgroundPromptImage
    case onePasswordImage
    case tagViewDeletionImage
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
        case .infoImage:
            return "icon_info"
        case .pinImage:
            return "icon_pin"
        case .sharedImage:
            return "icon_shared"
        case .navigationBarBackgroundImage:
            return "navigation_bar_background"
        case .navigationBarBackgroundPromptImage:
            return "navigation_bar_background_prompt"
        case .onePasswordImage:
            return "icon_onepassword"
        case .tagViewDeletionImage:
            return "button_delete_small"
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
