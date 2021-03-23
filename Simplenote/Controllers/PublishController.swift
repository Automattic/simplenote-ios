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

        NoticeController.shared.present(published ? Notices.publishing : Notices.unpublishing)
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
            NoticeController.shared.present(self.publishedNotice(for: wrapper.note), completion: {
                self.callbackMap.removeValue(forKey: wrapper.note.simperiumKey)
            })
            return
        }

        if !wrapper.note.published {
            wrapper.block(.unpublished)
            NoticeController.shared.present(unpublishedNotice(for: wrapper.note))

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

extension PublishController {
    private func unpublishedNotice(for note: Note) -> Notice {
        let action = NoticeAction(title: Notices.undoMessage) {
            self.updatePublishState(for: note, to: true, completion: { (_) in
                NoticeController.shared.present(self.publishedNotice(for: note))
            })
        }
        return Notice(message: Notices.unpublishMessage, action: action)
    }

    private func publishedNotice(for note: Note) -> Notice {
        let action = NoticeAction(title: Notices.copyLinkMessage) {
            UIPasteboard.general.copyPublicLink(to: note)
            NoticeController.shared.present(Notices.linkCopied)

            if let wrapper = self.callbackMap[note.simperiumKey] {
                wrapper.block(.linkCopied)
                self.callbackMap.removeValue(forKey: wrapper.note.simperiumKey)
            }
        }
        return Notice(message: Notices.publishSuccessfulmessage, action: action)
    }

    private func copyLinkWasPressed(on note: Note) {
        UIPasteboard.general.copyPublicLink(to: note)
        NoticeController.shared.present(Notices.linkCopied)

        if let wrapper = self.callbackMap[note.simperiumKey] {
            wrapper.block(.linkCopied)
        }
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

private struct Notices {
    static let publishing = Notice(message: NSLocalizedString("Publishing...", comment: "Notice of publishing action"), action: nil)
    static let unpublishing = Notice(message: NSLocalizedString("Unpublishing...", comment: "Notice of unpublishing action"), action: nil)
    static let linkCopied = Notice(message: NSLocalizedString("Link Copied.", comment: "Link was copied"), action: nil)

    static let copyLinkMessage = NSLocalizedString("Copy link.", comment: "Copy link action")
    static let unpublishMessage = NSLocalizedString("Unpublish successful.", comment: "Notice of publishing unsuccessful")
    static let undoMessage = NSLocalizedString("Undo", comment: "Undo action")

    static let publishSuccessfulmessage = NSLocalizedString("Publish Successful.", comment: "Notice up succesful publishing")
}
