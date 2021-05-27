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
    static let currentEngineBaseURL: String = {
        BuildConfiguration.current == .internal ? SPCredentials.experimentalEngineURL : SPCredentials.defaultEngineURL
    }()

    /// AppEngine: Endpoints
    ///
    static let resetPasswordURL     = currentEngineBaseURL + "/reset/?redirect=simplenote://launch&email="
    static let settingsURL          = currentEngineBaseURL + "/settings"
    static let signupURL            = currentEngineBaseURL + "/account/request-signup"
    static let verificationURL      = currentEngineBaseURL + "/account/verify-email/"
}
