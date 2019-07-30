import Foundation
import UIKit


// MARK: - Simplenote Named Images
//
@objc
enum UIImageName: Int, CaseIterable {
    case backImage
    case pinImage
    case sharedImage
    case navigationBarShadowImage
    case navigationBarBackgroundImage
    case navigationBarBackgroundPromptImage
    case searchBarBackgroundImage
    case tagViewDeletionImage
}


// MARK: - Public Methods
//
extension UIImageName {

    /// Returns the matching Legacy VSTheme Key
    ///
    var legacyImageKey: ThemeImageKey {
        switch self {
        case .backImage:
            return .backImage
        case .pinImage:
            return .pinImage
        case .sharedImage:
            return .sharedImage
        case .navigationBarShadowImage:
            return .navigationBarShadowImage
        case .navigationBarBackgroundImage:
            return .navigationBarBackgroundImage
        case .navigationBarBackgroundPromptImage:
            return .navigationBarBackgroundPromptImage
        case .searchBarBackgroundImage:
            return .searchBarBackgroundImage
        case .tagViewDeletionImage:
            return .tagViewDeletionImage
        }
    }
}
