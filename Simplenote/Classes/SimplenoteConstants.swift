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

    /// Simplenote: Interlink Maximum Title Length
    ///
    static let simplenoteInterlinkMaxTitleLength = 150

    /// Simplenote: Published Notes base URL
    ///
    static let simplenotePublishedBaseURL = "http://simp.ly/publish/"

    /// AppEngine: Base URL
    ///
    static let currentEngineBaseURL: NSString = {
        let output = BuildConfiguration.current == .internal ? SPCredentials.experimentalEngineURL : SPCredentials.defaultEngineURL
        return output as NSString
    }()

    // TODO: remove when account deletion api is set
    // Replace with currentEngineBaseURL
    static let testingAccountDeletionBaseURL: NSString = {
        return NSString(string: "https://pr-418-dot-simple-note-hrd.appspot.com/")
    }()

    /// AppEngine: Endpoints
    ///
    static let resetPasswordURL     = currentEngineBaseURL.appendingPathComponent("/reset/?redirect=simplenote://launch&email=")
    static let settingsURL          = currentEngineBaseURL.appendingPathComponent("/settings")
    static let signupURL            = currentEngineBaseURL.appendingPathComponent("/account/request-signup")
    static let verificationURL      = currentEngineBaseURL.appendingPathComponent("/account/verify-email/")
    static let accountDeletion      = testingAccountDeletionBaseURL.appendingPathComponent("/account/request-delete/")
}
