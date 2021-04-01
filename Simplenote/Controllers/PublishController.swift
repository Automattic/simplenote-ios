import Foundation
@objc
class PublishController: NSObject {
    private var observedNotes = [String: Note]()

    var onUpdate: ((Note) -> Void)?

    func updatePublishState(for note: Note, to published: Bool) {
        if note.published == published {
            return
        }

        changePublishState(for: note, to: published)

        beginListeningForChanges(to: note, timeOut: Constants.timeOut)

        publishStateChanged(for: note)
    }

    private func changePublishState(for note: Note, to published: Bool) {
        note.published = published
        note.modificationDate = Date()
        SPAppDelegate.shared().save()
    }

    private func publishStateChanged(for note: Note) {
        onUpdate?(note)
    }
}

extension PublishController {

    // MARK: Listeners
    private func beginListeningForChanges(to note: Note, timeOut: TimeInterval) {
        observedNotes[note.simperiumKey] = note

        DispatchQueue.main.asyncAfter(deadline: .now() + timeOut) {
            self.endListeningForChanges(to: note)
        }
    }

    private func endListeningForChanges(to note: Note) {
        observedNotes.removeValue(forKey: note.simperiumKey)
    }

    // MARK: Listener Notifications
    @objc(didReceiveUpdateNotificationForKey:withMemberNames:)
    func didReceiveUpdateNotification(for key: String, with memberNames: NSArray) {
        guard memberNames.contains(Constants.observedProperty),
              let note = observedNotes[key] else {
            return
        }

        publishStateChanged(for: note)
        endListeningForChanges(to: note)
    }

    @objc(didReceiveDeleteNotificationsForKey:)
    func didReceiveDeleteNotification(for key: String) {
        guard let note = observedNotes[key] else {
            return
        }

        endListeningForChanges(to: note)
    }
}

private struct Constants {
    static let timeOut = TimeInterval(5)
    static let observedProperty = "publishURL"
}
