import Foundation
import SimplenoteFoundation
import SimplenoteSearch

class WidgetDataController {

    /// Data Controller
    ///
    let coreDataManager: CoreDataManager

    /// Notes Controller
    ///
    private lazy var notesController = ResultsController<Note>(
        viewContext: coreDataManager.managedObjectContext,
        matching: predicateForNotes(),
        sortedBy: [NSSortDescriptor.descriptorForNotes(sortMode: noteSortMode)]
    )

    /// Initialization
    ///
    init(coreDataManager: CoreDataManager) throws {
        guard let isLoggedIn = UserDefaults(suiteName: SimplenoteConstants.sharedGroupDomain)?.bool(forKey: .accountIsLoggedIn),
              isLoggedIn else {
            throw StorageError.appConfigurationError
        }

        self.coreDataManager = coreDataManager
        coreDataManager.managedObjectContext.persistentStoreCoordinator = coreDataManager.persistentStoreCoordinator
    }

    /// Sort mode for widgets.  Fetched from main apps sort setting
    ///
    private var noteSortMode: SortMode {
        guard let defaults = UserDefaults(suiteName: SimplenoteConstants.sharedGroupDomain) else {
            return SortMode.alphabeticallyAscending
        }

        return SortMode(rawValue: defaults.integer(forKey: .listSortMode))
            ?? SortMode.alphabeticallyAscending
    }


    // MARK: Public Methods
    //

    /// Fetch notes with given tag and limit
    /// If no tag is specified, will fetch notes that are not deleted. If there is no limit specified it will fetch all of the notes
    ///
    func notes(withTag tag: String? = nil, limit: Int = 0) throws -> [Note] {
        notesController.limit = limit

        if let tag = tag {
            notesController.predicate = predicateForNotes(withTag: tag)
        }

        do {
            try notesController.performFetch()
        } catch {
            throw StorageError.fetchError
        }

        return notesController.fetchedObjects
    }

    /// Returns note given a simperium key
    ///
    func note(forSimperiumKey key: String) -> Note? {
        notesController.predicate = predicateForNotes()

        do {
            try notesController.performFetch()
        } catch {
            return nil
        }

        return notesController.fetchedObjects.first { note in
            note.simperiumKey == key
        }
    }

    /// Creates a predicate for notes given a tag name.  If not specified the predicate is for all notes that are not deleted
    ///
    private func predicateForNotes(withTag tag: String? = nil) -> NSPredicate {
        guard let tag = tag else {
            return NSPredicate.predicateForNotes(deleted: false)
        }
        return NSPredicate.predicateForNotes(tag: tag)
    }
}
