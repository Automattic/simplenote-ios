import Foundation

// MARK: - Simplenote Constants!
//
@objcMembers
class SimplenoteConstants: NSObject {

    /// Password Validation Rules
    ///
    static let passwordRules = "minlength: 8; maxlength: 50;"

    /// Simplenote: Scheme
    ///
    static let simplenoteScheme = "simplenote"

    /// Simplenote: Interlink Host
    ///
    static let simplenoteInterlinkHost = "note"

    /// Simplenote: Tag list Host
    ///
    static let simplenoteInternalTagHost = "list"

    /// Simplenote: Interlink Maximum Title Length
    ///
    static let simplenoteInterlinkMaxTitleLength = 150

    /// Simplenote: Published Notes base URL
    ///
    static let simplenotePublishedBaseURL = "http://simp.ly/publish/"
    
    /// Simplenote: Current Platform
    ///
    static let simplenotePlatformName = "iOS"

    /// Simplenote: Domain for shared group directory
    ///
    static let sharedGroupDomain = "group.\(Bundle.main.rootBundleIdentifier ?? "com.codality.NotationalFlow")"

    /// AppEngine: Base URL
    ///
    static let currentEngineBaseURL = SPCredentials.defaultEngineURL as NSString

    /// AppEngine: Endpoints
    ///
    static let resetPasswordURL     = currentEngineBaseURL.appendingPathComponent("/reset/?redirect=simplenote://launch&email=")
    static let settingsURL          = currentEngineBaseURL.appendingPathComponent("/settings")
    static let loginRequestURL      = currentEngineBaseURL.appendingPathComponent("/account/request-login")
    static let loginCompletionURL   = currentEngineBaseURL.appendingPathComponent("/account/complete-login")
    static let signupURL            = currentEngineBaseURL.appendingPathComponent("/account/request-signup")
    static let verificationURL      = currentEngineBaseURL.appendingPathComponent("/account/verify-email/")
    static let accountDeletionURL   = currentEngineBaseURL.appendingPathComponent("/account/request-delete/")
}
