import Foundation

struct NoticeAction {
    let title: ActionMessage
    let handler: () -> Void

    func localizedTitle() -> String {
        switch title {
        case .retry:
            return NSLocalizedString("Retry", comment: "Retry action title")
        case .undo:
            return NSLocalizedString("Undo", comment: "Undo action title")
        }
    }
}

enum ActionMessage {
    case undo
    case retry
}
