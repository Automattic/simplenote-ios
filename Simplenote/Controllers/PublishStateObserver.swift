import Foundation

class PublishStateObserver {
    private var callbackMap = [String: PublishListenWrapper]()

    // MARK: Listeners
    func beginListeningForChanges(to note: Note, timeOut: TimeInterval, onResponse: @escaping (PublishStateObserver, Note) -> Void) {
        callbackMap[note.simperiumKey] = PublishListenWrapper(note: note, block: onResponse)

        DispatchQueue.main.asyncAfter(deadline: .now() + timeOut) {
            self.endListeningForChanges(to: note)
        }
    }

    func endListeningForChanges(to note: Note) {
        callbackMap.removeValue(forKey: note.simperiumKey)
    }

    // MARK: Listener Notifications
    func didReceiveUpdateNotification(for key: String, with memberNames: NSArray) {
        guard memberNames.contains("publishURL"),
              let wrapper = callbackMap[key] else {
            return
        }

        wrapper.block(self, wrapper.note)
    }

    func didReceiveDeleteNotification(for key: String) {
        guard let wrapper = callbackMap[key] else {
            return
        }

        endListeningForChanges(to: wrapper.note)
    }
}

private struct PublishListenWrapper {
    let note: Note
    let block: (PublishStateObserver, Note) -> Void
}
