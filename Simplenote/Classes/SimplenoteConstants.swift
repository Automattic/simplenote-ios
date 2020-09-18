import Foundation


// MARK: - Simplenote Constants!
//
@objcMembers
class SimplenoteConstants: NSObject {

    /// Password Validation Rules
    ///
    static let passwordRules = "minlength: 8; maxlength: 50;"

    /// Pinlock Keychain Constants
    ///
    static let pinlockKeychainAccount = "SimplenotePin"
    static let pinlockKeychainService = "SimplenotePin"
    static let timestampKeychainService = "simplenote-passcode"

    /// Password Reset URL
    ///
    static let resetPasswordURL = "https://app.simplenote.com/reset/?redirect=simplenote://launch&email="

    /// Share Extension Keychain Constants
    ///
    static let shareExtensionAccount = "Main"
    static let shareExtensionService = "SimplenoteShare"

    /// Simplenote: Scheme
    ///
    static let simplenoteScheme = "simplenote"

    /// Simplenote: Interlink Host
    ///
    static let simplenoteInterlinkHost = "note"

    /// Simplenote: Interlink Maximum Title Length
    ///
    static let simplenoteInterlinkMaxTitleLength = 150

    /// Tag(s) Max Length
    ///
    static let maximumTagLength = 256
}
