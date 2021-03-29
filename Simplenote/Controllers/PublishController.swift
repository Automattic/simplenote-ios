import Foundation

@objc
class PublishController: NSObject {
    private var callbackMap = [String: PublishListenWrapper]()
    private let timerFactory: TimerFactory
    private let publishListenerFactory: PublishListenerFactory
    private var timer: Timer?

    init(timerFactory: TimerFactory = TimerFactory(), publishListenerFactory: PublishListenerFactory = PublishListenerFactory()) {
        self.timerFactory = timerFactory
        self.publishListenerFactory = publishListenerFactory
    }

    func updatePublishState(for note: Note, to published: Bool, completion: @escaping (Note) -> Void) {
        if note.published == published {
            return
        }

        callbackMap[note.simperiumKey] = publishListenerFactory.publishListenerWrapper(note: note, block: completion)

        timer = timerFactory.scheduledTimer(with: Constants.timeOut, completion: {
            self.removeExpiredCallbacks()
        })

        changePublishState(for: note, to: published)
    }

    @objc(didReceiveUpdateFromSimperiumForKey:)
    func didReceiveUpdateFromSimperium(for key: String) {
        guard var wrapper = callbackMap[key] else {
            return
        }

        wrapper.update()
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
    case published
    case unpublished
}

struct PublishListenWrapper {
    let note: Note
    let block: (Note) -> Void
    var expiration: Date

    var isExpired: Bool {
        expiration.timeIntervalSinceNow < -Constants.timeOut
    }

    mutating func update() {
        block(note)
        setExpiration()
    }

    private mutating func setExpiration() {
        expiration = Date()
    }
}

class PublishListenerFactory {
    func publishListenerWrapper(note: Note, block: @escaping (Note) -> Void) -> PublishListenWrapper {
        return PublishListenWrapper(note: note, block: block, expiration: Date())
    }
}

private struct Constants {
    static let timeOut = TimeInterval(5)
}
