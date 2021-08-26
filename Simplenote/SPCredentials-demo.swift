/// Simplenote API Credentials
///
@objcMembers
class SPCredentials: NSObject {

    /// AppBot
    ///
    static let appbotKey = "not-required"

    /// AppCenter
    ///
    static let appCenterIdentifier = "not-required"

    /// Google Analytics
    ///
    static let googleAnalyticsID = "not-required"

    /// iTunes
    ///
    static let iTunesAppID = "not-required"
    static let iTunesReviewURL = URL(string: "http://not.required")!

    /// Sentry
    ///
    static let sentryDSN = "https://00000000000000000000000000000000@sentry.io/00000000"

    /// Simperium: Credentials
    ///
    static let simperiumAppID = "history-analyst-dad"
    static let simperiumApiKey = "6805ca9a091e45ada8a9d8988367f14e"

    /// Simperium: Reserved Object Keys
    ///
    static let simperiumEmailVerificationObjectKey = "not-required"
    static let simperiumPreferencesObjectKey = "not-required"
    static let simperiumSettingsObjectKey = "not-required"

    /// Simperium: Endpoints
    ///
    static let defaultEngineURL = "https://app.simplenote.com"

    /// Simplenote's Send Feedback
    ///
    static let simplenoteFeedbackURL = URL(string: "https://not.required")!
    static let simplenoteFeedbackMail = "not.required@not.required.com"

    /// WordPressSSO
    ///
    static let wpcomClientID = "not-required"
    static let wpcomRedirectURL = "not-required"
}
