import Foundation


// MARK: - Simplenote Constants!
//
@objcMembers
class SimplenoteConstants: NSObject {

    /// Password Validation Rules
    ///
    static let passwordRules = "minlength: 8; maxlength: 50;"

    /// Password Reset URL
    ///
    static let resetPasswordURL = "https://app.simplenote.com/reset/?redirect=simplenote://launch&email="

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


// MARK: - Keychain Constants
//
struct SimplenoteKeychain {

    /// Pinlock
    ///
    static let pinlockAccount = "SimplenotePin"
    static let pinlockService = "SimplenotePin"

    /// Timestamp
    ///
    static let timestampAccount = "Main"
    static let timestampService = "simplenote-passcode"

    /// Share Extension
    ///
    static let shareAccount = "Main"
    static let shareService = "SimplenoteShare"
}
