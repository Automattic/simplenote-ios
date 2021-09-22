import Foundation


// MARK: - NotesListFilter
//
enum NotesListFilter: Equatable {
    case everything
    case deleted
    case untagged
    case tag(name: String)
}


// MARK: - NotesListFilter: Public API
//
extension NotesListFilter {

    /// Initializes the ListFilter for a given `selectedTag`
    ///
    /// TODO: As of now, Simplenote keeps track of the selectedTag as a string, in the AppDelegate.
    /// Once we've Swifted enough (AppDelegate + TagListViewController), remove this initializer.
    ///
    init(selectedTag: String?) {
        guard let tag = selectedTag, !tag.isEmpty else {
            self = .everything
            return
        }

        switch selectedTag {
        case kSimplenoteTrashKey:
            self = .deleted
        case kSimplenoteUntaggedKey:
            self = .untagged
        default:
            self = .tag(name: tag)
        }
    }


    /// Filter's visible Title
    ///
    var title: String {
        switch self {
        case .everything:
            return NSLocalizedString("All Notes", comment: "Title: No filters applied")
        case .deleted:
            return NSLocalizedString("Trash", comment: "Title: Trash Tag is selected")
        case .untagged:
            return NSLocalizedString("Untagged", comment: "Title: Untagged Notes are onscreen")
        case .tag(let name):
            return name
        }
    }
}
