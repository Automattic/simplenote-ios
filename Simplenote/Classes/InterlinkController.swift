import Foundation
import SimplenoteFoundation


// MARK: - InterlinkController
//
class InterlinkController {

    /// View Context
    ///
    private let viewContext: NSManagedObjectContext

    /// ResultsController: In charge of CoreData Queries!
    ///
    private lazy var resultsController = ResultsController<Note>(viewContext: viewContext, sortedBy: [
        NSSortDescriptor(keyPath: \Note.content, ascending: true)
    ])

    /// In-Memory Filtered Notes
    /// -   Our Storage does not split `Title / Body`. Filtering by keywords in the title require a NSPredicate + Block
    /// -   The above is awfully underperformant.
    /// -   Most efficient approach code wise / speed involves simply keeping a FRC instance, and filtering it as needed
    ///
    private var filteredNotes = [Note]()


    init(viewContext: NSManagedObjectContext = SPAppDelegate.shared().managedObjectContext) {
        self.viewContext = viewContext
        setupResultsController()
    }
}



// MARK: - Public API
//
extension InterlinkController {

    /// Refreshes the Autocomplete Results. Returns `true` when there are visible rows.
    /// - Important:
    ///     By design, whenever there are no results we won't be refreshing the TableView. Instead, we'll stick to the "old results".
    ///     This way we get to avoid the awkward visual effect of "empty autocomplete view"
    ///
    func refreshInterlinks(for keyword: String, excluding excludedID: NSManagedObjectID?) -> Bool {
        filteredNotes = filterNotes(resultsController.fetchedObjects, byTitleKeyword: keyword, excluding: excludedID)
        return filteredNotes.count > .zero
    }

    var numberOfNotes: Int {
        filteredNotes.count
    }

    func note(at index: Int) -> Note {
        filteredNotes[index]
    }
}


// MARK: - Private
//
private extension InterlinkController {

    /// Initializes the Results Controller
    ///
    func setupResultsController() {
        resultsController.predicate = NSPredicate.predicateForNotes(deleted: false)
        try? resultsController.performFetch()
    }

    /// Filters a collection of notes by their Title contents, excluding a specific Object ID.
    ///
    /// - Important: Why do we perform an *in memory* filtering?
    ///     - CoreData's SQLite store does not support block based predicates
    ///     - RegExes aren't diacritic + case insensitve friendly
    ///     - It's easier and anyone can follow along!
    ///
    func filterNotes(_ notes: [Note], byTitleKeyword keyword: String, excluding excludedID: NSManagedObjectID?, limit: Int = Settings.maximumNumberOfResults) -> [Note] {
        var output = [Note]()
        let normalizedKeyword = keyword.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)

        for note in notes where note.objectID != excludedID {
            note.ensurePreviewStringsAreAvailable()
            guard let normalizedTitle = note.titlePreview?.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil),
                  normalizedTitle.contains(normalizedKeyword)
            else {
                continue
            }

            output.append(note)

            if output.count >= limit {
                break
            }
        }

        return output
    }
}


// MARK: - Settings!
//
private enum Settings {
    static let maximumNumberOfResults = 15
}
