import Foundation

struct Notice {
    // TODO: needs to be equatable

    let message: NoticeMessage
    let action: NoticeAction?

    var hasAction: Bool {
        return action != nil
    }

    init(message: NoticeMessage, action: NoticeAction? = nil) {
        self.message = message
        self.action = action
    }

    func localizedMessage() -> String {
        switch message {
        case .linkCopied:
            return NSLocalizedString("Link copied.", comment: "Link Copied Notice")
        case .publishingNote:
            return NSLocalizedString("Publishing note...", comment: "Publishing note notice")
        case .unpublishingNote:
            return NSLocalizedString("Unpublishing note...", comment: "Unpublishing note notice")
        case .notePublished:
            return NSLocalizedString("Note published.", comment: "Note Published notice")
        case .publishFailed:
            return NSLocalizedString("Could not publish note.", comment: "Could not publish note notice")
        case .noteUnpublished:
            return NSLocalizedString("Note unpublished.", comment: "Note unpublished notice" )
        case .unpublishFailed:
            return NSLocalizedString("Could not unpublish note.", comment: "Could not unpublish note notice")
        case .noteTrashed:
            return NSLocalizedString("Note trashed.", comment: "Note trashed notice")
        }
    }
}

enum NoticeMessage {
    case linkCopied
    case publishingNote
    case unpublishingNote
    case notePublished
    case publishFailed
    case noteUnpublished
    case unpublishFailed
    case noteTrashed
}
