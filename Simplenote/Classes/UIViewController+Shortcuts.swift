import Foundation
import CoreSpotlight


// MARK: - UIViewController Shortcuts Helpers
//
extension UIViewController {

    /// Registers the Launch Activity
    ///
    @objc
    func registerLaunchActivity() {
        let title = NSLocalizedString("Open Simplenote", comment: "Siri Suggestion to open our app")
        let activity = NSUserActivity(type: .launch, title: title)

        userActivity = activity
    }

    /// Registers the New Note Activity
    ///
    @objc
    func registerNewNoteActivity() {
        let title = NSLocalizedString("Create a New Note", comment: "Siri Suggestion to create a New Note")
        let activity = NSUserActivity(type: .newNote, title: title)

        userActivity = activity
    }

    /// Register the Open Note Activity
    ///
    @objc
    func registerOpenNoteActivity(note: Note) {
        guard let uniqueIdentifier = note.simperiumKey, let preview = note.titlePreview else {
            NSLog("Note with missing SimperiumKey!!")
            return
        }

        let title = NSLocalizedString("Open \"\(preview)\"", comment: "Siri Suggestion to open a specific Note")
        let activity = NSUserActivity(type: .openNote, title: title)
        activity.userInfo = [CSSearchableItemActivityIdentifier: uniqueIdentifier]

        userActivity = activity
    }
}
