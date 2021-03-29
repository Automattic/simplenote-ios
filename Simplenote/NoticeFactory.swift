import Foundation

struct NoticeFactory {
    static func linkCopied() -> Notice {
        return Notice(message: Messages.copyLink, action: nil)
    }

    static func publishing() -> Notice {
        Notice(message: Messages.publishing, action: nil)
    }

    static func unpublishing() -> Notice {
        return Notice(message: Messages.unpublishing, action: nil)
    }

    static func noteTrashed(_ note: Note) -> Notice {
        let action = NoticeAction(title: Messages.undo) {
            SPObjectManager.shared().restoreNote(note)
        }
        let notice = Notice(message: Messages.trashed, action: action)
        return notice
    }

    static func unpublished(_ note: Note) -> Notice {
        let action = NoticeAction(title: Messages.undo) {
            SPAppDelegate.shared().publishController.updatePublishState(for: note, to: true, completion: { (_) in
                NoticeController.shared.present(NoticeFactory.published(note))
            })
        }
        let notice = Notice(message: Messages.unpublished, action: action)
        return notice
    }

    static func published(_ note: Note) -> Notice {
        let action = NoticeAction(title: Messages.copyLink) {
            UIPasteboard.general.copyPublicLink(to: note)
            NoticeController.shared.present(NoticeFactory.linkCopied())
        }
        let notice = Notice(message: Messages.published, action: action)
        return notice
    }
}

extension NoticeFactory {
    private enum Messages {
        static let copyLink = NSLocalizedString("Copy link", comment: "Copy link action")
        static let publishing = NSLocalizedString("Publishing...", comment: "Notice of publishing action")
        static let unpublishing = NSLocalizedString("Unpublishing...", comment: "Notice of unpublishing action")
        static let undo = NSLocalizedString("Undo", comment: "Undo action")
        static let trashed = NSLocalizedString("Note Trashed", comment: "Note trashed notification")
        static let unpublished = NSLocalizedString("Unpublish successful", comment: "Notice of publishing unsuccessful")
        static let published = NSLocalizedString("Publish Successful", comment: "Notice up succesful publishing")
    }
}
