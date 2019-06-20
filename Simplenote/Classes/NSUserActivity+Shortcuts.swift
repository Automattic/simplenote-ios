import Foundation
import CoreSpotlight
import Intents
import MobileCoreServices



// MARK: - NSUserActivity Convenience Methods
//
extension NSUserActivity {

    /// Initializes a UserActivity Instance with a given Activity Type
    ///
    convenience init(type: ActivityType, title: String, suggestedInvocationPhrase: String? = nil) {
        self.init(activityType: type.rawValue)

        self.title = title
        isEligibleForSearch = true
        isEligibleForHandoff = false

        if #available(iOS 12.0, *) {
            isEligibleForPrediction = true
            self.suggestedInvocationPhrase = suggestedInvocationPhrase ?? title
        }
    }

    /// Convenience wrapper API that removes all of the shared UserActivities, whenever the API allows.
    ///
    @objc
    class func deleteAllSavedUserActivitiesIfPossible() {
        if #available(iOS 12.0, *) {
            deleteAllSavedUserActivities {
                // No-Op: The SDK's API... doesn't take a nil callback. Neat!
            }
        }
    }
}
