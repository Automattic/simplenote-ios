import Foundation
import CoreSpotlight
import Intents
import MobileCoreServices



// MARK: - NSUserActivity Convenience Methods
//
extension NSUserActivity {

    /// Initializes a UserActivity Instance with a given Activity Type
    ///
    convenience init(type: ActivityType) {
        self.init(activityType: type.rawValue)
        expirationDate = type.expirationDate
        title = type.title

        if let description = type.description {
            let contentAttributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
            contentAttributeSet.contentDescription = description
            contentAttributeSet.contentCreationDate = nil // Set this to nil so it doesn't display in spotlight
            contentAttributeSet.relatedUniqueIdentifier = type.rawValue
            self.contentAttributeSet = contentAttributeSet
        }

        isEligibleForSearch = true
        isEligibleForHandoff = false

        if #available(iOS 12.0, *) {
            isEligibleForPrediction = true
            suggestedInvocationPhrase = type.suggestedInvocationPhrase
        }
    }
}
