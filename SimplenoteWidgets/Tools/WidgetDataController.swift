import Foundation
import SimplenoteFoundation
import SimplenoteSearch

class WidgetDataController {
    let coreDataManager: CoreDataManager

    private lazy var notesController = ResultsController<Note>(
        viewContext: coreDataManager.managedObjectContext,
        sortedBy: [NSSortDescriptor.descriptorForNotes(sortMode: sortMode)]
    )

    init() throws {
        // TODO: Check if main app is logged in, if not throw

        self.coreDataManager = try CoreDataManager(StorageSettings().sharedStorageURL)
        coreDataManager.managedObjectContext.persistentStoreCoordinator = coreDataManager.persistentStoreCoordinator

        setupNotesController()
    }

    private var sortMode: SortMode {
        let sortModeSetting = UserDefaults(suiteName: SimplenoteConstants.sharedGroupDomain)?.integer(forKey: .listSortMode) ?? 0
        return SortMode(rawValue: sortModeSetting) ?? SortMode.alphabeticallyAscending
    }

    var excludeDeletedNotes = true

    private func setupNotesController() {
        if excludeDeletedNotes {
            notesController.predicate = NSPredicate.predicateForNotes(deleted: false)
        }
    }

    func notes() -> [Note] {
        do {
            try notesController.performFetch()
        } catch {
            #warning("Need to do a better job of error handling")
            NSLog("Couldn't fetch")
        }

        return notesController.fetchedObjects
    }
}
