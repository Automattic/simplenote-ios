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
        matching: state.predicateForNotes(searchKey: searchKey),
        sortedBy: [NSSortDescriptor.descriptorForNotes(sortMode: noteSortMode)],
        limit: state.fetchLimitForNotes()
    )

    init(coreDataManager: CoreDataManager, state: WidgetState) throws {
        guard let isLoggedIn = UserDefaults(suiteName: SimplenoteConstants.sharedGroupDomain)?.bool(forKey: .accountIsLoggedIn),
              isLoggedIn else {
            throw StorageError.appConfigurationError
        }

        self.coreDataManager = coreDataManager
        coreDataManager.managedObjectContext.persistentStoreCoordinator = coreDataManager.persistentStoreCoordinator

        self.state = state
    }

    private var noteSortMode: SortMode {
        guard let defaults = UserDefaults(suiteName: SimplenoteConstants.sharedGroupDomain) else {
            return SortMode.alphabeticallyAscending
        }

        return SortMode(rawValue: defaults.integer(forKey: .listSortMode))
            ?? SortMode.alphabeticallyAscending
    }

    let state: WidgetState
    
    var searchKey: String?

    func notes() throws -> [Note] {
        do {
            try notesController.performFetch()
        } catch {
            throw StorageError.fetchError
        }

        return notesController.fetchedObjects
    }

    func note(forSimperiumKey key: String) -> Note? {
        return notesController.fetchedObjects.first { note in
            note.simperiumKey == key
        }
    }
}
