import Foundation
import CoreSpotlight
import Intents
import MobileCoreServices

// MARK: - NSUserActivity Convenience Methods
//
extension NSUserActivity {

    /// Initializes a UserActivity Instance with a given Activity Type
    ///
    /// - Parameters:
    ///     - type: The Activity Type we're representing
    ///     - title: Display text that will show up in Spotlight
    ///     - suggestedInvocationPhrase: Optional hint that shows up whenever the user adds a shortcut. When nil, we'll
    ///       assume the *title* is a valid Suggested Invocation Phrase.
    ///
    convenience init(type: ActivityType, title: String, suggestedInvocationPhrase: String? = nil) {
        self.init(activityType: type.rawValue)

        self.title = title
        isEligibleForSearch = true
        isEligibleForHandoff = false
        isEligibleForPrediction = true
        self.suggestedInvocationPhrase = suggestedInvocationPhrase ?? title
    }
}
