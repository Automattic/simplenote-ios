import Foundation


// MARK: - NotesListController
//
class NotesListController: NSObject {

    /// Main Context
    ///
    private let viewContext: NSManagedObjectContext

    /// Notes Controller
    ///
    private lazy var notesController: ResultsController<Note> = {
        ResultsController<Note>(viewContext: viewContext, matching: state.predicateForNotes(filter: filter), sortedBy: sortMode.descriptorsForNotes)
    }()

    /// Tags Controller
    ///
    private lazy var tagsController: ResultsController<Tag> = {
        ResultsController<Tag>(viewContext: viewContext, matching: state.predicateForTags(), sortedBy: sortMode.descriptorsForTags)
    }()

    /// Notes Changes: We group all of the Sections + Object changes, and notify our listeners in batch.
    ///
    private var noteObjectChanges = [ResultsObjectChange]()
    private var noteSectionChanges = [ResultsSectionChange]()

    /// Tags Changes: We group all of the Sections + Object changes, and notify our listeners in batch.
    ///
    private var tagObjectChanges = [ResultsObjectChange]()
    private var tagSectionChanges = [ResultsSectionChange]()

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

    /// Callback to be executed whenever the NotesController or TagsController were updated
    /// - NOTE: This only happens as long as the current state must render such entities!
    ///
    var onBatchChanges: ((_ rowChanges: [ResultsObjectChange], _ sectionChanges: [ResultsSectionChange]) -> Void)?


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
        case .searching where state.sectionIndexForTags == indexPath.section:
            return tagsController.fetchedObjects[indexPath.row]
        case .searching where state.sectionIndexForNotes == indexPath.section:
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

    /// Returns the Fetched Note with the specified SimperiumKey (if any)
    ///
    @objc
    func note(forSimperiumKey key: String) -> Note? {
        return notesController.fetchedObjects.first { note in
            note.simperiumKey == key
        }
    }

    /// Reloads all of the FetchedObjects, as needed
    ///
    @objc
    func performFetch() {
// TODO: Does refetching cause changes?
        removePendingTagChanges()
        removePendingNoteChanges()

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


// MARK: - Private API: ResultsController Refreshing
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


// MARK: - Private API: Realtime Refreshing
//
private extension NotesListController {

    func startListeningToNoteEvents() {
        notesController.onDidChangeObject = { [weak self] change in
            self?.noteObjectChanges.append( change )
        }

        notesController.onDidChangeSection = { [weak self] change in
            self?.noteSectionChanges.append( change )
        }

        notesController.onDidChangeContent = { [weak self] in
            self?.notesControllerDidChange()
        }
    }

    func startListeningToTagEvents() {
        tagsController.onDidChangeObject = { [weak self] change in
            self?.tagObjectChanges.append( change )
        }

        tagsController.onDidChangeSection = { [weak self] change in
            self?.tagSectionChanges.append( change )
        }

        tagsController.onDidChangeContent = { [weak self] in
            self?.tagsControllerDidChange()
        }
    }

    func notesControllerDidChange() {
        if state.displaysNotes {
            let (objectChanges, sectionChanges) = adjustedNoteChanges(forState: state)
            onBatchChanges?(objectChanges, sectionChanges)
        }

        removePendingNoteChanges()
    }

    func tagsControllerDidChange() {
        if state.displaysTags {
            onBatchChanges?(tagObjectChanges, tagSectionChanges)
        }

        removePendingTagChanges()
    }

    func removePendingTagChanges() {
        tagObjectChanges = []
        tagSectionChanges = []
    }

    func removePendingNoteChanges() {
        noteObjectChanges = []
        noteSectionChanges = []
    }

    /// When in Search Mode, we'll need to mix Tags + Notes. There's one slight problem: NSFetchedResultsController Is completely unaware that the
    /// actual SectionIndex for Notes is (1) rather than (0). In that case we'll need to re-map Object and Section changes.
    ///
    func adjustedNoteChanges(forState state: NotesListState) -> ([ResultsObjectChange], [ResultsSectionChange]) {
        guard state.requiresNoteSectionIndexAdjustments else {
            return (noteObjectChanges, noteSectionChanges)
        }

        let transposedObjectChanges = noteObjectChanges.map { $0.transpose(toSection: state.sectionIndexForNotes) }
        let transposedSectionChanges = noteSectionChanges.map { $0.transpose(toSection: state.sectionIndexForNotes) }

        return (transposedObjectChanges, transposedSectionChanges)
    }
}
