import Foundation

@objc
class PublishController: NSObject {
    private var callbackMap = [String: PublishListenWrapper]()

    @discardableResult
    func updatePublishState(for note: Note, to published: Bool, completion: @escaping (PublishState) -> Void) -> Any? {
        if note.published == published {
            return nil
        }

        let wrapper = PublishListenWrapper(note: note, block: completion)
        callbackMap[note.simperiumKey] = wrapper

        SPTracker.trackEditorNotePublishEnabled(published)
        changePublishState(for: note, to: published)

        NoticeController.shared.present(published ? NoticeFactory.publishing : NoticeFactory.unpublishing)
        wrapper.block(published ? .publishing : .unpublished)

        return wrapper
    }

    @objc(didReceiveUpdateFromSimperiumForKey:)
    func didReceiveUpdateFromSimperium(for key: NSString) {
        guard let wrapper = callbackMap[key as String] else {
            return
        }

        if wrapper.note.published && wrapper.note.publishURL != nil {
            wrapper.block(.published)
            NoticeController.shared.present(NoticeFactory.published(wrapper.note))
            return
        }

        if !wrapper.note.published {
            wrapper.block(.unpublished)
            NoticeController.shared.present(NoticeFactory.unpublished(wrapper.note))

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
    case linkCopied
}

private class PublishListenWrapper: NSObject {
    let note: Note
    let block: (PublishState) -> Void

    init(note: Note, block: @escaping (PublishState) -> Void) {
        self.note = note
        self.block = block
    }
}
