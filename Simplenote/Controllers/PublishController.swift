import Foundation

class PublishStateObserver {
    private var callbackMap = [String: PublishListenWrapper]()

    func beginListeningForChanges(to note: Note, onResponse: @escaping (Note) -> Void) {
        callbackMap[note.simperiumKey] = PublishListenWrapper(note: note, block: onResponse)
    }

    func endListeningForChanges(to note: Note) {
        callbackMap.removeValue(forKey: note.simperiumKey)
    }

    func didReceiveUpdateFromSimperium(for key: String, with memberNames: NSArray) {
        if !memberNames.contains("publishURL") {
            return
        }

        guard var wrapper = callbackMap[key] else {
            return
        }

        wrapper.update()
    }
}

struct PublishListenWrapper {
    let note: Note
    let block: (Note) -> Void
    let expiration = Date()

    var isExpired: Bool {
        return expiration.timeIntervalSinceNow < -Constants.timeOut
    }

    mutating func update() {
        block(note)
    }
}

private struct Constants {
    static let timeOut = TimeInterval(5)
}


class PublishController {
    let publishStateObserver = PublishStateObserver()

    func updatePublishState(for note: Note, to published: Bool) {
        if note.published == published {
            return
        }

        changePublishState(for: note, to: published)

        publishStateObserver.beginListeningForChanges(to: note) { (note) in
            self.handlePublishObserverResponse(note)
        }

        presentPendingPublishNotice(published)
    }

    private func changePublishState(for note: Note, to published: Bool) {
        note.published = published
        note.modificationDate = Date()
        SPAppDelegate.shared().save()
    }

    private func presentPendingPublishNotice(_ published: Bool) {
        let notice: Notice = published ? NoticeFactory.publishing() : NoticeFactory.unpublishing()
        NoticeController.shared.present(notice)
    }

    private func handlePublishObserverResponse(_ note: Note) {
        switch note.publishState {
        case .published:
            let notice = NoticeFactory.published(note)
            NoticeController.shared.present(notice)
        case .unpublished:
            let notice = NoticeFactory.unpublished(note)
            NoticeController.shared.present(notice)
        }
        publishStateObserver.endListeningForChanges(to: note)
    }
}
