import Foundation
import UIKit


// MARK: - Bundle: Simplenote Methods
//
extension Bundle {

    /// Returns the Bundle Short Version String.
    ///
    @objc
    var shortVersionString: String {
        let version = infoDictionary?[Keys.shortVersionString] as? String
        return version ?? ""
    }

    /// AppEngine Base URL
    ///
    var engineBaseURL: String? {
        infoDictionary?[Keys.engineBaseURL] as? String
    }

    /// Simperium: Authentication Endpoint
    ///
    var simperiumAuthURL: String? {
        infoDictionary?[Keys.simperiumAuthURL] as? String
    }

    /// Simperium: Host Header
    ///
    var simperiumHost: String? {
        infoDictionary?[Keys.simperiumHost] as? String
    }
}


// MARK: - Private Keys
//
private enum Keys {
    static let engineBaseURL        = "APP_ENGINE_BASE_URL"
    static let simperiumAuthURL     = "AUTH_URL"
    static let simperiumHost        = "AUTH_HOST"
    static let shortVersionString   = "CFBundleShortVersionString"
}
