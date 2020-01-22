import Foundation


// MARK: - NotesListController
//
class NotesListController: NSObject {

    /// Main Context
    ///
    private let viewContext: NSManagedObjectContext

    /// Notes Controller
    ///
    private lazy var notesController = ResultsController<Note>(viewContext: viewContext,
                                                               matching: state.predicateForNotes(filter: filter),
                                                               sortedBy: sortMode.descriptorsForNotes)

    /// Tags Controller
    ///
    private lazy var tagsController = ResultsController<Tag>(viewContext: viewContext,
                                                             matching: state.predicateForTags(),
                                                             sortedBy: sortMode.descriptorsForTags)

    /// FSM Current State
    ///
    private(set) var state: NotesListState = .results {
        didSet {
            guard oldValue != state else {
                return
            }

            refreshEverything()
        }
    }

    /// Filter to be applied (whenever we're not in Search Mode)
    ///
    var filter: NotesListFilter = .everything {
        didSet {
            guard oldValue != filter else {
                return
            }

            refreshPredicates()
        }
    }

    /// SortMode to be applied
    ///
    var sortMode: SortMode = .alphabeticallyAscending {
        didSet {
            guard oldValue != sortMode else {
                return
            }

            refreshSortDescriptors()
        }
    }


    /// Designated Initializer
    ///
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        super.init()
    }
}


// MARK: - Public API
//
extension NotesListController {

    /// Returns the Receiver's Number of Objects
    ///
    @objc
    var numberOfObjects: Int {
        switch state {
        case .results:
            return notesController.numberOfObjects
        case .searching:
            return tagsController.numberOfObjects + notesController.numberOfObjects
        }
    }

    /// Returns the Receiver's Sections
    ///
    @objc
    var sections: [ResultsSectionInfo] {
        switch state {
        case .results:
            return notesController.sections
        case .searching:
            return tagsController.sections + notesController.sections
        }
    }

    /// Returns the Object at a given IndexPath (If any!)
    ///
    @objc(objectAtIndexPath:)
    func object(at indexPath: IndexPath) -> Any? {
        switch state {
        case .results:
            return notesController.object(at: indexPath)
        case .searching where SearchSections(rawValue: indexPath.section) == .tags:
            return tagsController.fetchedObjects[indexPath.row]
        case .searching where SearchSections(rawValue: indexPath.section) == .notes:
            return notesController.fetchedObjects[indexPath.row];
        default:
            return nil
        }
    }

    /// Returns the IndexPath for a given Object (If any!)
    ///
    @objc(indexPathForObject:)
    func indexPath(forObject object: Any) -> IndexPath? {
        switch (state, object) {
        case (.results, let note as Note):
            return notesController.indexPath(forObject: note)
        case (.searching, let tag as Tag):
            return tagsController.fetchedObjects.firstIndex(of: tag).map { row in
                IndexPath(row: row, section: SearchSections.tags.rawValue)
            }
        case (.searching, let note as Note):
            return notesController.fetchedObjects.firstIndex(of: note).map { row in
                IndexPath(row: row, section: SearchSections.notes.rawValue)
            }
        default:
            return nil
        }
    }

    /// Reloads all of the FetchedObjects, as needed
    ///
    @objc
    func performFetch() {
        if state.displaysNotes {
            try? notesController.performFetch()
        }

        if state.displaysTags {
            try? tagsController.performFetch()
        }
    }
}


// MARK: - Search API
//
extension NotesListController {

    /// Sets the receiver in Search Mode
    ///
    @objc
    func beginSearch() {
        // TODO: we should actually switch to `state = .history`
    }

    /// Refreshes the FetchedObjects so that they match a given Keyword
    ///
    @objc
    func refreshSearchResults(keyword: String) {
        guard !keyword.isEmpty else {
            return
        }

        state = .searching(keyword: keyword)
    }

    /// Sets the receiver in "Results Mode"
    ///
    @objc
    func endSearch() {
        state = .results
    }
}


// MARK: - Convenience APIs
//
extension NotesListController {

    /// Returns the Fetched Note with the specified SimperiumKey (if any)
    ///
    @objc
    func note(forSimperiumKey key: String) -> Note? {
        return notesController.fetchedObjects.first { note in
            note.simperiumKey == key
        }
    }
}


// MARK: - Private API
//
private extension NotesListController {

    func refreshPredicates() {
        notesController.predicate = state.predicateForNotes(filter: filter)
        tagsController.predicate = state.predicateForTags()
    }

    func refreshSortDescriptors() {
        notesController.sortDescriptors = sortMode.descriptorsForNotes
        tagsController.sortDescriptors = sortMode.descriptorsForTags
    }

    func refreshEverything() {
        refreshPredicates()
        refreshSortDescriptors()
        performFetch()
    }
}


// MARK: - SearchSections Constants
//
private enum SearchSections: Int {
    case tags = 0
    case notes = 1
}
