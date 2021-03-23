import Foundation

@objc
class PublishController: NSObject {
    private var callbackMap = [String: PublishListenWrapper]()

    func updatePublishState(for note: Note, to published: Bool, completion: @escaping (PublishState) -> Void) {
        if note.published == published {
            return
        }

        let wrapper = PublishListenWrapper(note: note, block: completion)
        callbackMap[note.simperiumKey] = wrapper

        SPTracker.trackEditorNotePublishEnabled(published)
        changePublishState(for: note, to: published)

        wrapper.block(published ? .publishing : .unpublished)
    }

    @objc(didReceiveUpdateFromSimperiumForKey:)
    func didReceiveUpdateFromSimperium(for key: NSString) {
        guard let wrapper = callbackMap[key as String] else {
            return
        }

        if wrapper.note.published && wrapper.note.publishURL != nil {
            wrapper.block(.published)
            return
        }

        if !wrapper.note.published {
            wrapper.block(.unpublished)

            callbackMap.removeValue(forKey: wrapper.note.simperiumKey)
            return
        }
    }

    private func changePublishState(for note: Note, to published: Bool) {
        note.published = published
        note.modificationDate = Date()
        SPAppDelegate.shared().save()
    }
}

enum PublishState {
    case publishing
    case published
    case unpublishing
    case unpublished
}

private class PublishListenWrapper: NSObject {
    let note: Note
    let block: (PublishState) -> Void

    init(note: Note, block: @escaping (PublishState) -> Void) {
        self.note = note
        self.block = block
    }
}
