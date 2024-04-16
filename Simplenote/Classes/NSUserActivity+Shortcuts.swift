import Foundation
import CoreSpotlight

// MARK: - Simplenote's NSUserActivities
//
extension NSUserActivity {

    /// Registers the Launch Activity
    ///
    @objc
    class func launchActivity() -> NSUserActivity {
        let title = NSLocalizedString("Open Simplenote", comment: "Siri Suggestion to open our app")
        let activity = NSUserActivity(type: .launch, title: title)

        return activity
    }

    /// Registers the New Note Activity
    ///
    @objc
    class func newNoteActivity() -> NSUserActivity {
        let title = NSLocalizedString("Create a New Note", comment: "Siri Suggestion to create a New Note")
        let activity = NSUserActivity(type: .newNote, title: title)

        return activity
    }

    /// Register the Open Note Activity
    ///
    @objc
    class func openNoteActivity(for note: Note) -> NSUserActivity? {
        guard let uniqueIdentifier = note.simperiumKey, let preview = note.titlePreview else {
            NSLog("Note with missing SimperiumKey!!")
            return nil
        }

        let title = NSLocalizedString("Open \"\(preview)\"", comment: "Siri Suggestion to open a specific Note")
        let activity = NSUserActivity(type: .openNote, title: title)
        activity.userInfo = [CSSearchableItemActivityIdentifier: uniqueIdentifier]

        return activity
    }
}
