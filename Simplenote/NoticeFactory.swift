import Foundation

struct NoticeFactory {
    static let linkCopied = Notice(message: NoticeFactory.copyLinkMessage, action: nil)
    static let publishing = Notice(message: NSLocalizedString("Publishing...", comment: "Notice of publishing action"), action: nil)
    static let unpublishing = Notice(message: NSLocalizedString("Unpublishing...", comment: "Notice of unpublishing action"), action: nil)

    static func noteTrashed(_ note: Note) -> Notice {
        let action = NoticeAction(title: NSLocalizedString("Undo", comment: "Undo action tilte")) {
            SPObjectManager.shared().restoreNote(note)
        }
        let notice = Notice(message: NSLocalizedString("Note Trashed.", comment: "Note trashed notification"), action: action)
        return notice
    }

    static func unpublished(_ note: Note) -> Notice {
        let action = NoticeAction(title: NSLocalizedString("Undo", comment: "Undo action")) {
            SPAppDelegate.shared().publishController.updatePublishState(for: note, to: true, completion: { (_) in
                NoticeController.shared.present(NoticeFactory.published(note))
            })
        }
        let notice = Notice(message: NSLocalizedString("Unpublish successful.", comment: "Notice of publishing unsuccessful"), action: action)
        return notice
    }

    static func published(_ note: Note) -> Notice{
        let action = NoticeAction(title: NoticeFactory.copyLinkMessage) {
            UIPasteboard.general.copyPublicLink(to: note)
            NoticeController.shared.present(NoticeFactory.linkCopied)
        }
        let notice = Notice(message: NSLocalizedString("Publish Successful.", comment: "Notice up succesful publishing"), action: action)
        return notice
    }
}

extension NoticeFactory {
    static let copyLinkMessage = NSLocalizedString("Copy link.", comment: "Copy link action")
}
