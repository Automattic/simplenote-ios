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

    /// Settings URL
    ///
    static let settingsURL = "https://app.simplenote.com/settings"

    /// Verification URL
    ///
    static let verificationURL = "https://app.simplenote.com/account/verify-email/"

    /// Signup URL
    ///
    static let signupURL = "https://app.simplenote.com/request-signup"

    /// Simplenote: Scheme
    ///
    static let simplenoteScheme = "simplenote"

    /// Simplenote: Interlink Host
    ///
    static let simplenoteInterlinkHost = "note"

    /// Simplenote: Interlink Maximum Title Length
    ///
    static let simplenoteInterlinkMaxTitleLength = 150

    /// Simplenote: Published Notes base URL
    ///
    static let simplenotePublishedBaseURL = "http://simp.ly/publish/"
}
