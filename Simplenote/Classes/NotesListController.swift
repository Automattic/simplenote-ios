import Foundation
import SimplenoteFoundation
import SimplenoteSearch


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
                                                               sortedBy: state.descriptorsForNotes(sortMode: sortMode))

    /// Tags Controller
    ///
    private lazy var tagsController = ResultsController<Tag>(viewContext: viewContext,
                                                             matching: state.predicateForTags(),
                                                             sortedBy: state.descriptorsForTags(),
                                                             limit: limitForTagResults)

    /// Indicates the maximum number of Tag results we'll yield
    ///
    ///     -  Known Issues: If new Tags are added in a second device, and sync'ed while we're in Search Mode,
    ///        ResultsController won't respect the limit.
    ///
    let limitForTagResults = 5

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

    /// SortMode to be applied to **regular** results
    ///
    var sortMode: SortMode = .alphabeticallyAscending {
        didSet {
            guard oldValue != sortMode else {
                return
            }

            refreshSortDescriptors()
        }
    }

    /// Callback to be executed whenever the NotesController or TagsController were updated
    /// - NOTE: This only happens as long as the current state must render such entities!
    ///
    var onBatchChanges: ((_ sectionsChangeset: ResultsSectionsChangeset, _ rowsChangeset: ResultsObjectsChangeset) -> Void)?


    /// Designated Initializer
    ///
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        super.init()
        startListeningToNoteEvents()
        startListeningToTagEvents()
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
    var sections: [NotesListSection] {
        switch state {
        case .results:
            return [
                NotesListSection(title: state.sectionTitleForNotes, objects: notesController.fetchedObjects)
            ]
        case .searching:
            return [
                NotesListSection(title: state.sectionTitleForTags, objects: tagsController.fetchedObjects),
                NotesListSection(title: state.sectionTitleForNotes, objects: notesController.fetchedObjects)
            ]
        }
    }

    /// Returns the Object at a given IndexPath (If any!)
    ///
    @objc(objectAtIndexPath:)
    func object(at indexPath: IndexPath) -> Any? {
        switch state {
        case .results:
            return notesController.object(at: indexPath)
        case .searching where state.sectionIndexForTags == indexPath.section:
            let tags = tagsController.fetchedObjects
            return indexPath.row < tags.count ? tags[indexPath.row] : nil
        case .searching where state.sectionIndexForNotes == indexPath.section:
            let notes = notesController.fetchedObjects
            return indexPath.row < notes.count ? notes[indexPath.row] : nil
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
                IndexPath(row: row, section: state.sectionIndexForTags)
            }
        case (.searching, let note as Note):
            return notesController.fetchedObjects.firstIndex(of: note).map { row in
                IndexPath(row: row, section: state.sectionIndexForNotes)
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
        // NO-OP: Initially meant for History, keeping it around for both consistency and future purposes.
    }

    /// Refreshes the FetchedObjects so that they match a given Keyword
    ///
    /// -   Note: Whenever the Keyword is actually empty, we'll fallback to regular results. Capisci?
    ///
    @objc
    func refreshSearchResults(keyword: String) {
        let query = SearchQuery(searchText: keyword)
        guard !query.isEmpty else {
            state = .results
            return
        }
        state = .searching(query: query)
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


// MARK: - Private API: ResultsController Refreshing
//
private extension NotesListController {

    func refreshPredicates() {
        notesController.predicate = state.predicateForNotes(filter: filter)
        tagsController.predicate = state.predicateForTags()
    }

    func refreshSortDescriptors() {
        notesController.sortDescriptors = state.descriptorsForNotes(sortMode: sortMode)
        tagsController.sortDescriptors = state.descriptorsForTags()
    }

    func refreshEverything() {
        refreshPredicates()
        refreshSortDescriptors()
        performFetch()
    }
}


// MARK: - Private API: Realtime Refreshing
//
private extension NotesListController {

    func startListeningToNoteEvents() {
        notesController.onDidChangeContent = { [weak self] (sectionsChangeset, objectsChangeset) in
            self?.notifyNotesDidChange(sectionsChangeset: sectionsChangeset, objectsChangeset: objectsChangeset)
        }
    }

    func startListeningToTagEvents() {
        tagsController.onDidChangeContent = { [weak self] (sectionsChangeset, objectsChangeset) in
            self?.notifyTagsDidChange(sectionsChangeset: sectionsChangeset, objectsChangeset: objectsChangeset)
        }
    }

    /// When in Search Mode, we'll need to mix Tags + Notes. There's one slight problem: NSFetchedResultsController Is completely unaware that the
    /// actual SectionIndex for Notes is (1) rather than (0). In that case we'll need to re-map Object and Section changes.
    ///
    func notifyNotesDidChange(sectionsChangeset: ResultsSectionsChangeset, objectsChangeset: ResultsObjectsChangeset) {
        guard state.displaysNotes else {
            return
        }

        guard state.requiresNoteSectionIndexAdjustments else {
            onBatchChanges?(sectionsChangeset, objectsChangeset)
            return
        }

        let transposedSectionsChangeset = sectionsChangeset.transposed(toSection: state.sectionIndexForNotes)
        let transposedObjectsChangeset = objectsChangeset.transposed(toSection: state.sectionIndexForNotes)

        onBatchChanges?(transposedSectionsChangeset, transposedObjectsChangeset)
    }

    func notifyTagsDidChange(sectionsChangeset: ResultsSectionsChangeset, objectsChangeset: ResultsObjectsChangeset) {
        guard state.displaysTags else {
            return
        }

        onBatchChanges?(sectionsChangeset, objectsChangeset)
    }
}
