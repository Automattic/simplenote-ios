import Foundation

class PublishStateObserver {
    private var callbackMap = [String: PublishListenWrapper]()
    private let timerFactory: TimerFactory
    private var timer: Timer?

    init(timerFactory: TimerFactory = TimerFactory()) {
        self.timerFactory = timerFactory
    }

    func beginListeningForChanges(to note: Note, completion: @escaping (Note) -> Void) {
        callbackMap[note.simperiumKey] = PublishListenWrapper(note: note, block: completion)
        prepareTimerIfNeeded()
    }

    @objc(didReceiveUpdateFromSimperiumForKey:)
    func didReceiveUpdateFromSimperium(for key: String) {
        guard var wrapper = callbackMap[key] else {
            return
        }

        wrapper.update()
        removeCallbackFor(key: key)
    }

    private func removeExpiredCallbacks() {
        for callback in callbackMap {
            if callback.value.isExpired {
                removeCallbackFor(key: callback.key)
            }
        }
    }

    private func removeCallbackFor(key: String) {
        callbackMap.removeValue(forKey: key)
    }

    private func prepareTimerIfNeeded() {
        guard let currentTimer = timer else {
            timer = timeOutTimer()
            return
        }

        if !currentTimer.isValid {
            timer = timeOutTimer()
        }
    }

    private func timeOutTimer() -> Timer {
        return timerFactory.repeatingTimer(with: Constants.timeOut) { (timer) in
            if self.callbackMap.isEmpty {
                timer.invalidate()
            } else {
                self.removeExpiredCallbacks()
            }
        }
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
    }
}
