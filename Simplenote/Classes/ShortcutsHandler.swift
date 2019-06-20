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
            return false
        }

        switch type {
        case .launch:
            break
        case .newNote:
            SPAppDelegate.shared().presentNewNoteEditor()
        case .openNote,
             .openSpotlightItem:
            presentNote(for: userActivity)
        }

        return true
    }

    /// Displays a Note, whenever the UniqueIdentifier is contained within a given UserActivity instance.
    ///
    private func presentNote(for userActivity: NSUserActivity) {
        guard let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String else {
            return
        }

        SPAppDelegate.shared().presentNote(withUniqueIdentifier: uniqueIdentifier)
    }
}
