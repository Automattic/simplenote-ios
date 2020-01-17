import Foundation


// MARK: - NotesListState
//
enum NotesListState {
    case results
//  TODO: case history
    case searching(keyword: String)
}


// MARK: - NotesListState: Public API
//
extension NotesListState {

    /// Indicates if the NotesList should display Note Entities for the current state
    ///
    var displaysNotes: Bool {
        return true
    }

    /// Indicates if the NotesList should display Tag Entities for the current state
    ///
    var displaysTags: Bool {
        guard case .searching = self else {
            return false
        }

        return true
    }

    /// Returns the SectionIndex for Notes, in the current state
    ///
    var sectionIndexForNotes: Int {
        switch self {
        case .searching:
            return 1
        default:
            return .zero
        }
    }

    /// Returns the SectionIndex for Tags, in the current state
    ///
    var sectionIndexForTags: Int {
        return .zero
    }

    /// Indicates if we should adjust SectionIndexes for ResultsController Changes entities
    ///
    var requiresNoteSectionIndexAdjustments: Bool {
        guard case .searching = self else {
            return false
        }

        return true
    }

    /// Returns a NSPredicate to filter out Notes in the current state, with the specified Filter
    ///
    func predicateForNotes(filter: NotesListFilter) -> NSPredicate? {
        var subpredicates = [NSPredicate]()

        switch self {
        case .results:
            subpredicates.append( NSPredicate.predicateForNotes(deleted: filter == .deleted) )

            switch filter {
            case .tag(let name):
                subpredicates.append( NSPredicate.predicateForNotes(tag: name) )
            case .untagged:
                subpredicates.append( NSPredicate.predicateForUntaggedNotes() )
            default:
                break
            }
        case .searching(let keyword):
            subpredicates += [
                NSPredicate.predicateForNotes(deleted: false),
                NSPredicate.predicateForNotes(searchText: keyword)
            ]
        }

        return NSCompoundPredicate(andPredicateWithSubpredicates: subpredicates)
    }

    /// Returns a NSPredicate to filter out Tags in the current state
    ///
    func predicateForTags() -> NSPredicate? {
        guard case let .searching(keyword) = self else {
            return nil
        }

        return NSPredicate.predicateForTag(name: keyword)
    }
}


// MARK: - Equality
//
func ==(lhs: NotesListState, rhs: NotesListState) -> Bool {
    switch (lhs, rhs) {
    case (.results, .results):
        return true
    case let (.searching(lKeyword), .searching(rKeyword)):
        return lKeyword == rKeyword
    default:
        return false
    }
}

func !=(lhs: NotesListState, rhs: NotesListState) -> Bool {
    return !(lhs == rhs)
}
