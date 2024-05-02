import Foundation
import CoreSpotlight
import Intents

// MARK: - AppDelegate Shortcuts Methods
//
class ShortcutsHandler: NSObject {

    /// This is, gentlemen, a singleton.
    ///
    @objc
    static var shared = ShortcutsHandler()

    /// Is User authenticated?
    ///
    private var isAuthenticated: Bool {
        return SPAppDelegate.shared().simperium.user?.authenticated() == true
    }

    /// Supported Activities
    ///
    private let activities = [
        NSUserActivity.newNoteActivity(),
        NSUserActivity.launchActivity()
    ]

    /// Removes all of the shared UserActivities, whenever the API allows.
    ///
    @objc
    func unregisterSimplenoteActivities() {
        NSUserActivity.deleteAllSavedUserActivities {
            // No-Op: The SDK's API... doesn't take a nil callback. Neat!
        }
    }

    /// Handles a UserActivity instance. Returns true on success.
    ///
    @objc
    func handleUserActivity(_ userActivity: NSUserActivity) -> Bool {
        guard let type = ActivityType(rawValue: userActivity.activityType) else {
            return false
        }

        guard isAuthenticated else {
            return type == .launch
        }

        switch type {
        case .launch:
            break
        case .newNote, .newNoteShortcut:
            SPAppDelegate.shared().presentNewNoteEditor()
        case .openNote, .openSpotlightItem:
            presentNote(for: userActivity)
        case .openNoteShortcut:
            presentNote(for: userActivity.interaction)
        }

        return true
    }
}

// MARK: - Home Screen Quick Actions
//
extension ShortcutsHandler {
    private var shortcutUserInfoNoteIdentifierKey: String {
        return "simperium_key"
    }

    /// Clears home screen quick actions
    ///
    func clearHomeScreenQuickActions() {
        UIApplication.shared.shortcutItems = nil
    }

    /// Updates home screen quick actions in case they are empty
    ///
    @objc
    func updateHomeScreenQuickActionsIfNeeded() {
        guard UIApplication.shared.shortcutItems?.isEmpty != false else {
            return
        }
        updateHomeScreenQuickActions(with: nil)
    }

    /// Updates home screen quick actions
    ///
    func updateHomeScreenQuickActions(with recentNote: Note?) {
        UIApplication.shared.shortcutItems = [
            searchItem,
            newNoteItem,
            noteItem(with: recentNote)
        ].compactMap({ $0 })
    }

    /// Handles an application shortcut
    ///
    @objc
    func handleApplicationShortcut(_ shortcut: UIApplicationShortcutItem) {
        guard isAuthenticated, let type = ApplicationShortcutItemType(rawValue: shortcut.type) else {
            return
        }

        switch type {
        case .search:
            SPAppDelegate.shared().presentSearch()
        case .newNote:
            SPAppDelegate.shared().presentNewNoteEditor()
        case .note:
            if let simperiumKey = shortcut.userInfo?[shortcutUserInfoNoteIdentifierKey] as? String {
                SPAppDelegate.shared().presentNoteWithSimperiumKey(simperiumKey)
            }
        }
    }

    private var searchItem: UIApplicationShortcutItem {
        let icon = UIApplicationShortcutIcon(templateImageName: UIImageName.search.lightAssetFilename)
        return UIApplicationShortcutItem(type: ApplicationShortcutItemType.search.rawValue,
                                         localizedTitle: NSLocalizedString("Search", comment: "Home screen quick action: Search"),
                                         localizedSubtitle: nil,
                                         icon: icon,
                                         userInfo: nil)
    }

    private var newNoteItem: UIApplicationShortcutItem {
        let icon = UIApplicationShortcutIcon(templateImageName: UIImageName.newNote.lightAssetFilename)
        return UIApplicationShortcutItem(type: ApplicationShortcutItemType.newNote.rawValue,
                                         localizedTitle: NSLocalizedString("New Note", comment: "Home screen quick action: New Note"),
                                         localizedSubtitle: nil,
                                         icon: icon,
                                         userInfo: nil)
    }

    private func noteItem(with note: Note?) -> UIApplicationShortcutItem? {
        guard let note = note, let simperiumKey = note.simperiumKey else {
            return nil
        }

        let icon = UIApplicationShortcutIcon(templateImageName: UIImageName.allNotes.lightAssetFilename)
        return UIApplicationShortcutItem(type: ApplicationShortcutItemType.note.rawValue,
                                         localizedTitle: NSLocalizedString("Recent", comment: "Home screen quick action: Recent Note"),
                                         localizedSubtitle: note.titlePreview,
                                         icon: icon,
                                         userInfo: [shortcutUserInfoNoteIdentifierKey: simperiumKey as NSSecureCoding])
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

        SPAppDelegate.shared().presentNoteWithSimperiumKey(uniqueIdentifier)
    }

    func presentNote(for interaction: INInteraction?) {
        guard let interaction,
              let activity = interaction.intentResponse?.userActivity,
              let uniqueIdentifier = activity.userInfo?["OpenNoteIntentHandlerIdentifierKey"] as? String else {
            return
        }

        SPAppDelegate.shared().presentNoteWithSimperiumKey(uniqueIdentifier)
    }
}
