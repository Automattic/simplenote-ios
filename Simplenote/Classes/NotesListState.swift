import Foundation
import SimplenoteSearch

// MARK: - NotesListState
//
enum NotesListState: Equatable {
    case results
    case searching(query: SearchQuery)
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

    /// Returns the SectionTitle for Notes, in the current state
    ///
    var sectionTitleForNotes: String? {
        switch self {
        case .searching:
            return NSLocalizedString("Notes", comment: "Notes Header (Search Mode)")
        default:
            return nil
        }
    }

    /// Returns the SectionTitle for Tags, in the current state
    ///
    var sectionTitleForTags: String? {
        switch self {
        case .searching:
            return NSLocalizedString("Search by Tag", comment: "Tags Header (Search Mode)")
        default:
            return nil
        }
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
        case .searching(let query):
            subpredicates += [
                NSPredicate.predicateForNotes(deleted: false),
                NSPredicate.predicateForNotes(query: query)
            ]
        }

        return NSCompoundPredicate(andPredicateWithSubpredicates: subpredicates)
    }

    /// Returns a NSPredicate to filter out Tags in the current state
    ///
    func predicateForTags() -> NSPredicate? {
        guard case let .searching(query) = self else {
            return nil
        }

        return NSPredicate.predicateForTags(in: query)
    }

    /// Returns a collection of NSSortDescriptors that, once applied to a Notes collection, the specified SortMode will be reflected
    ///
    func descriptorsForNotes(sortMode: SortMode) -> [NSSortDescriptor] {
        var descriptors = [NSSortDescriptor]()

        switch self {
        case .results:
            descriptors.append(NSSortDescriptor.descriptorForPinnedNotes())
        default:
            // Search shouldn't be affected by pinned notes
            break
        }

        descriptors.append(NSSortDescriptor.descriptorForNotes(sortMode: sortMode))

        return descriptors
    }

    /// Returns a collection of NSSortDescriptors that, once applied to a Tags collection, the specified SortMode will be reflected
    ///
    func descriptorsForTags() -> [NSSortDescriptor] {
        return [
            NSSortDescriptor.descriptorForTags()
        ]
    }
}
