import Foundation

@objc
class PublishController: NSObject {
    private var callbackMap = [String: PublishListenWrapper]()
    private let timerFactory: TimerFactory
    private let publishListenerFactory: PublishListenerFactory

    init(timerFactory: TimerFactory = TimerFactory(), publishListenerFactory: PublishListenerFactory = PublishListenerFactory()) {
        self.timerFactory = timerFactory
        self.publishListenerFactory = publishListenerFactory
    }

    func updatePublishState(for note: Note, to published: Bool, completion: @escaping (Note) -> Void) {
        if note.published == published {
            return
        }

        callbackMap[note.simperiumKey] = publishListenerFactory.publishListenerWrapper(note: note, block: completion)

        changePublishState(for: note, to: published)
    }

    @objc(didReceiveUpdateFromSimperiumForKey:)
    func didReceiveUpdateFromSimperium(for key: String) {
        guard var wrapper = callbackMap[key] else {
            return
        }

        wrapper.update()
        callbackMap.removeValue(forKey: key)
    }

    private func changePublishState(for note: Note, to published: Bool) {
        note.published = published
        note.modificationDate = Date()
        SPAppDelegate.shared().save()
    }
}

struct PublishListenWrapper {
    let note: Note
    let block: (Note) -> Void

    mutating func update() {
        block(note)
    }
}

class PublishListenerFactory {
    func publishListenerWrapper(note: Note, block: @escaping (Note) -> Void) -> PublishListenWrapper {
        return PublishListenWrapper(note: note, block: block)
    }
}

private struct Constants {
    static let timeOut = TimeInterval(5)
}
