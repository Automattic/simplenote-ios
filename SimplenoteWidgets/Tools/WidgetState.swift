import Foundation

enum WidgetState {
    case intents
    case noteWidget
    case listWidget
}

extension WidgetState {
    func fetchLimitForNotes() -> Int {
        switch self {
        case .intents:
            return 0
        case .noteWidget:
            return 1
        case .listWidget:
            return 8
        }
    }

    func predicateForNotes(searchKey: String? = nil) -> NSPredicate {
        switch self {
        case .intents:
            return NSPredicate.predicateForNotes(deleted: false)
        case .noteWidget:
            if let simperiumKey = searchKey {
                return NSPredicate(format: "simperiumKey IN %@", simperiumKey)
            } else {
                return NSPredicate.predicateForNotes(deleted: false)
            }
        case .listWidget:
            if let tag = searchKey {
                return NSPredicate(format: "tag IN %@", tag)
            } else {
                return NSPredicate.predicateForNotes(deleted: false)
            }
        }
    }
}
