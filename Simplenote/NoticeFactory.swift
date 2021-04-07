import Foundation

struct NoticeFactory {
    static func linkCopied(dismissible: Bool = false) -> Notice {
        Notice(message: Messages.linkCopied, action: nil, isDismissible: dismissible)
    }

    static func publishing(dismissible: Bool = false) -> Notice {
        Notice(message: Messages.publishing, action: nil, isDismissible: dismissible)
    }

    static func unpublishing(dismissible: Bool = false) -> Notice {
        Notice(message: Messages.unpublishing, action: nil, isDismissible: dismissible)
    }

    static func noteTrashed(_ note: Note, dismissible: Bool = false, onUndo: @escaping ()-> Void) -> Notice {
        let action = NoticeAction(title: Messages.undo, handler: onUndo)
        return Notice(message: Messages.trashed, action: action, isDismissible: dismissible)
    }

    static func unpublished(_ note: Note, dismissible: Bool = false, onUndo: @escaping ()-> Void) -> Notice {
        let action = NoticeAction(title: Messages.undo, handler: onUndo)
        return Notice(message: Messages.unpublished, action: action, isDismissible: dismissible)
    }

    static func published(_ note: Note, dismissible: Bool = false, onCopy: @escaping ()-> Void) -> Notice {
        let action = NoticeAction(title: Messages.copyLink, handler: onCopy)
        return Notice(message: Messages.published, action: action, isDismissible: dismissible)
    }
}

extension NoticeFactory {
    private enum Messages {
        static let copyLink = NSLocalizedString("Copy link", comment: "Copy link action")
        static let linkCopied = NSLocalizedString("Link copied", comment: "Link Copied alert")
        static let publishing = NSLocalizedString("Publishing...", comment: "Notice of publishing action")
        static let unpublishing = NSLocalizedString("Unpublishing...", comment: "Notice of unpublishing action")
        static let undo = NSLocalizedString("Undo", comment: "Undo action")
        static let trashed = NSLocalizedString("Note Trashed", comment: "Note trashed notification")
        static let unpublished = NSLocalizedString("Unpublish successful", comment: "Notice of publishing unsuccessful")
        static let published = NSLocalizedString("Publish Successful", comment: "Notice up succesful publishing")
    }
}
