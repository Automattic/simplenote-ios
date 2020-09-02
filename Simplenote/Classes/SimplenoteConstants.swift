import Foundation


// MARK: - Simplenote Constants!
//
@objcMembers
class SimplenoteConstants: NSObject {

    /// Interlink: Base URL
    ///
    static let interlinkBaseURL = "simplenote://note/"

    /// Interlink: Scheme
    ///
    static let interlinkScheme = "simplenote"

    /// Interlink: Maximum Title Length
    ///
    static let interlinkMaximumLength = 150

    /// Password Reset URL
    ///
    static let resetPasswordURL = "https://app.simplenote.com/reset/?redirect=simplenote://launch&email="

    /// Tag(s) Max Length
    ///
    static let maximumTagLength = 256
}
