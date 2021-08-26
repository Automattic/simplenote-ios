import Foundation

extension ListFilterKind {
    var description: String {
        switch self {
        case .tag:
            return NSLocalizedString("Tag", comment: "Display title for a User Tag")
        default:
            return NSLocalizedString("All Notes", comment: "Display title for All Notes")
        }
    }
}

extension WidgetTag {
    convenience init(kind: ListFilterKind, name: String? = nil) {
        switch kind {
        case .tag:
            self.init(identifier: name, display: name ?? Constants.unnamedTag)
        default:
            self.init(identifier: nil, display: kind.description)
        }
        self.kind = kind
    }

    var tagDescription: String {
        switch kind {
        case .tag:
            return displayString
        default:
            return kind.description
        }
    }
}

private struct Constants {
    static let allNotesDisplay = NSLocalizedString("All Notes", comment: "Display title for All Notes")
    static let unnamedTag = NSLocalizedString("Unnamed Tag", comment: "Default title for an unnamed tag")
}
