import Foundation

extension WidgetTag {
    convenience init(identifier: String?, display: String, kind: ListFilterKind) {
        self.init(identifier: identifier, display: display)
        self.kind = kind
    }

    convenience init(name: String? = nil, kind: ListFilterKind) {
        switch kind {
        case .allNotes, .unknown:
            self.init(identifier: nil, display: Constants.allNotesDisplay, kind: .allNotes)
        case .tag:
            self.init(identifier: name, display: name ?? Constants.unnamedTag, kind: .tag)
        }
    }

    static var allNotes: WidgetTag {
        WidgetTag.init(kind: .allNotes)
    }

    var tagDescription: String {
        switch kind {
        case .allNotes, .unknown:
            return Constants.allNotesDisplay
        case .tag:
            return displayString
        }
    }
}

private struct Constants {
    static let allNotesDisplay = NSLocalizedString("All Notes", comment: "Display title for All Notes")
    static let unnamedTag = NSLocalizedString("Unnamed Tag", comment: "Default title for an unnamed tag")
}
