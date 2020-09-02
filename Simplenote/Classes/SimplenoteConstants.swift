import Foundation


// MARK: - Simplenote Constants!
//
@objcMembers
class SimplenoteConstants: NSObject {

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
