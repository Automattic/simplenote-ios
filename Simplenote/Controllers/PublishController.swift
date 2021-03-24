import Foundation

@objc
class PublishController: NSObject {
    private var callbackMap: PublishMap
    private let timerFactory: TimerFactory

    init(timerFactory: TimerFactory = TimerFactory(), callbackMap: PublishMap = PublishMap()) {
        self.timerFactory = timerFactory
        self.callbackMap = callbackMap
    }

    func updatePublishState(for note: Note, to published: Bool, completion: @escaping (PublishState) -> Void) {
        if note.published == published {
            return
        }

        let wrapper = PublishListenWrapper(note: note, block: completion)
        callbackMap.container[note.simperiumKey] = wrapper

        SPTracker.trackEditorNotePublishEnabled(published)
        changePublishState(for: note, to: published)

        published ? update(wrapper, to: .publishing) : update(wrapper, to: .unpublishing)
    }

    @objc(didReceiveUpdateFromSimperiumForKey:)
    func didReceiveUpdateFromSimperium(for key: NSString) {
        guard let wrapper = callbackMap.container[key as String] else {
            return
        }

        if wrapper.note.published && wrapper.note.publishURL != nil {
            update(wrapper, to: .published)
            return
        }

        if !wrapper.note.published {
            update(wrapper, to: .unpublished)

            return
        }
    }

    private func update(_ wrapper: PublishListenWrapper, to state: PublishState) {
        wrapper.block(state)
        startTimer(in: wrapper)
    }

    private func changePublishState(for note: Note, to published: Bool) {
        note.published = published
        note.modificationDate = Date()
        SPAppDelegate.shared().save()
    }

    fileprivate func removeListenerCallback(for key: String) {
        callbackMap.container.removeValue(forKey: key)
    }

    fileprivate func startTimer(in wrapper: PublishListenWrapper) {
        wrapper.timer.invalidate()

        guard let key = wrapper.note.simperiumKey else {
            return
        }
        wrapper.timer = timerFactory.scheduledTimer(with: Constants.timeOut, completion: {
            self.removeListenerCallback(for: key)
        })
    }
}

enum PublishState {
    case publishing
    case published
    case unpublishing
    case unpublished
}

class PublishListenWrapper: NSObject {
    let note: Note
    let block: (PublishState) -> Void
    var timer: Timer

    init(note: Note, block: @escaping (PublishState) -> Void) {
        self.note = note
        self.block = block
        self.timer = Timer()
    }
}

class PublishMap {
    var container: [String: PublishListenWrapper]

    init(container: [String: PublishListenWrapper] = [String: PublishListenWrapper]()) {
        self.container = container
    }
}

private struct Constants {
    static let timeOut = TimeInterval(5)
}
