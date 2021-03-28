import Foundation

@objc
class PublishController: NSObject {
    private var callbackMap: [String: PublishListenWrapper]
    private let timerFactory: TimerFactory
    private var timer: Timer?

    init(timerFactory: TimerFactory = TimerFactory(), callbackMap: [String: PublishListenWrapper] = [String: PublishListenWrapper]()) {
        self.timerFactory = timerFactory
        self.callbackMap = callbackMap
    }

    func updatePublishState(for note: Note, to published: Bool, completion: @escaping (PublishState) -> Void) {
        if note.published == published {
            return
        }

        var wrapper = PublishListenWrapper(note: note, block: completion, expiration: Date())
        callbackMap[note.simperiumKey] = wrapper
        timer = timerFactory.scheduledTimer(with: Constants.timeOut, completion: {
            self.removeExpiredCallbacks()
        })

        changePublishState(for: note, to: published)

        published ? wrapper.update(to: .publishing) : wrapper.update(to: .unpublishing)
    }

    @objc(didReceiveUpdateFromSimperiumForKey:)
    func didReceiveUpdateFromSimperium(for key: String) {
        guard var wrapper = callbackMap[key] else {
            return
        }

        wrapper.handleListenResponse()
    }

    private func changePublishState(for note: Note, to published: Bool) {
        note.published = published
        note.modificationDate = Date()
        SPAppDelegate.shared().save()
    }

    private func removeListenerCallback(for key: String) {
        callbackMap.removeValue(forKey: key)
    }

    private func removeExpiredCallbacks() {
        for wrapper in callbackMap {
            if wrapper.value.isExpired {
                callbackMap.removeValue(forKey: wrapper.key)
            }
        }

        if !callbackMap.isEmpty {
            timer = timerFactory.scheduledTimer(with: Constants.timeOut, completion: {
                self.removeExpiredCallbacks()
            })
        }
    }
}

enum PublishState {
    case publishing
    case published
    case unpublishing
    case unpublished
}

struct PublishListenWrapper {
    let note: Note
    let block: (PublishState) -> Void
    var expiration: Date

    var isExpired: Bool {
        expiration.timeIntervalSinceNow < -Constants.timeOut
    }

    mutating func update(to state: PublishState) {
        block(state)
        setExpiration()
    }

    mutating func handleListenResponse() {
        if note.published && note.publishURL != nil {
            update(to: .published)
        }

        if !note.published {
            update(to: .unpublished)
        }

        setExpiration()
    }

    private mutating func setExpiration() {
        expiration = Date()
    }


}

private struct Constants {
    static let timeOut = TimeInterval(5)
}
