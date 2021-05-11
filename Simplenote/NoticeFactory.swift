import Foundation

struct NoticeFactory {
    static func linkCopied() -> Notice {
        Notice(message: Messages.linkCopied, action: nil)
    }

    static func publishing() -> Notice {
        Notice(message: Messages.publishing, action: nil)
    }

    static func unpublishing() -> Notice {
        Notice(message: Messages.unpublishing, action: nil)
    }

    static func noteTrashed(_ note: Note, onUndo: @escaping ()-> Void) -> Notice {
        let action = NoticeAction(title: Messages.undo, handler: onUndo)
        return Notice(message: Messages.trashed, action: action)
    }

    static func unpublished(_ note: Note, onUndo: @escaping ()-> Void) -> Notice {
        let action = NoticeAction(title: Messages.undo, handler: onUndo)
        return Notice(message: Messages.unpublished, action: action)
    }

    static func published(_ note: Note, onCopy: @escaping ()-> Void) -> Notice {
        let action = NoticeAction(title: Messages.copyLink, handler: onCopy)
        return Notice(message: Messages.published, action: action)
    }
}

extension NoticeFactory {
    private enum Messages {
        static let copyLink = NSLocalizedString("Copy link", comment: "Copy link action")
        static let linkCopied = NSLocalizedString("Link copied", comment: "Link Copied alert")
        static let publishing = NSLocalizedString("Publishing note...", comment: "Notice of publishing action")
        static let unpublishing = NSLocalizedString("Unpublishing note...", comment: "Notice of unpublishing action")
        static let undo = NSLocalizedString("Undo", comment: "Undo action")
        static let trashed = NSLocalizedString("Note Trashed", comment: "Note trashed notification")
        static let unpublished = NSLocalizedString("Unpublish successful", comment: "Notice of publishing unsuccessful")
        static let published = NSLocalizedString("Publish Successful", comment: "Notice up succesful publishing")
    }
}
