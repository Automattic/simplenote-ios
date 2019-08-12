import Foundation
import CoreSpotlight


// MARK: - AppDelegate Shortcuts Methods
//
class ShortcutsHandler: NSObject {

    /// This is, gentlemen, a singleton.
    ///
    @objc
    static var shared = ShortcutsHandler()

    /// Supported Activities
    ///
    private let activities = [
        NSUserActivity.newNoteActivity(),
        NSUserActivity.launchActivity()
    ]

    /// Registers all of the Simplenote-Y Activities.
    ///
    /// - Note:
    ///     1. Calling `becomeCurrent()` sequentially causes the OS not to register anything, (OR) register
    ///        just the last activity.
    ///     2. Not keeping the Activities around... also causes `becomeCurrent` to fail. That's why `activities` is
    ///        an ivar!
    ///
    @objc
    func registerSimplenoteActivities() {
        for (index, activity) in activities.enumerated() {
            let delay = DispatchTime.now() + DispatchTimeInterval.seconds(index)
            DispatchQueue.main.asyncAfter(deadline: delay) {
                activity.becomeCurrent()
            }
        }
    }

    /// Removes all of the shared UserActivities, whenever the API allows.
    ///
    @objc
    func unregisterSimplenoteActivities() {
        if #available(iOS 12.0, *) {
            NSUserActivity.deleteAllSavedUserActivities {
                // No-Op: The SDK's API... doesn't take a nil callback. Neat!
            }
        }
    }

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
        case .openNote, .openSpotlightItem:
            presentNote(for: userActivity)
        }

        return true
    }
}


// MARK: - Private Methods
//
private extension ShortcutsHandler {

    /// Displays a Note, whenever the UniqueIdentifier is contained within a given UserActivity instance.
    ///
    func presentNote(for userActivity: NSUserActivity) {
        guard let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String else {
            return
        }

        SPAppDelegate.shared().presentNote(withUniqueIdentifier: uniqueIdentifier)
    }
}
