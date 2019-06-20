import Foundation
import CoreSpotlight


// MARK: - AppDelegate Shortcuts Methods
//
class ShortcutsHandler: NSObject {

    /// This is, gentlemen, a singleton.
    ///
    @objc
    static var shared = ShortcutsHandler()

    /// Handles a UserActivity instance. Returns true on success.
    ///
    @objc
    func handleUserActivity(_ userActivity: NSUserActivity) -> Bool {
        guard let type = ActivityType(rawValue: userActivity.activityType) else {
            return presentNote(for: userActivity)
        }

        switch type {
        case .launch:
            break
        case .newNote:
            SPAppDelegate.shared().presentNewNoteEditor()
        }

        return true
    }

    /// Displays a Note, whenever the UniqueIdentifier is contained within a given UserActivity instance.
    ///
    func presentNote(for userActivity: NSUserActivity) -> Bool {
        guard let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String else {
            return false
        }

        SPAppDelegate.shared().presentNote(withUniqueIdentifier: uniqueIdentifier)

        return true
    }
}
