import Foundation


// MARK: - Simplenote Constants!
//
@objcMembers
class SimplenoteConstants: NSObject {

    /// Base URL used to interlink Notes
    ///
    static let interlinkBaseURL = "simplenote://note/"

    /// Password Reset URL
    ///
    static let resetPasswordURL = "https://app.simplenote.com/reset/?redirect=simplenote://launch&email="

    /// Tag(s) Max Length
    ///
    static let maximumTagLength = 256
}
