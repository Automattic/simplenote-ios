import Foundation

enum WidgetsState {
    case standard
    case noteMissing
    case tagDeleted
    case loggedOut
    case noteLocked
    case listLocked
}

extension WidgetsState {
    var message: String {
        switch self {
        case .standard:
            return String()
        case .noteMissing:
            return NSLocalizedString("Note no longer available", comment: "Widget warning if note is deleted")
        case .tagDeleted:
            return NSLocalizedString("Tag no longer available", comment: "Widget warning if tag is deleted")
        case .loggedOut:
            return NSLocalizedString("Log in to see your notes", comment: "Widget warning if user is logged out")
        case .noteLocked:
            return NSLocalizedString("Unlock to see your note", comment: "Widget warning if pin lock is enabled")
        case .listLocked:
            return NSLocalizedString("Unlock to see your note list", comment: "Widget warning if pin lock is enabled")
        }
    }
}
