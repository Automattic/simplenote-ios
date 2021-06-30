import Intents
import CoreData

class IntentHandler: INExtension {
    private var dataManager: CoreDataManager = {
        let storageSettings = StorageSettings()
        let coreDataManager = CoreDataManager(storageSettings: storageSettings)
        coreDataManager.managedObjectContext.persistentStoreCoordinator = coreDataManager.persistentStoreCoordinator

        return coreDataManager
    }()

    private func fetchedResultsController<T: SPManagedObject>(ofType type: T.Type) -> NSFetchedResultsController<T> {
        let fetchRequest = NSFetchRequest<T>()
        let sortDescriptor = NSSortDescriptor(key: "modificationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        let entityDescription = NSEntityDescription.entity(forEntityName: String(describing: type.self), in: dataManager.managedObjectContext)
        fetchRequest.entity = entityDescription

        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataManager.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)

    }

    override func handler(for intent: INIntent) -> Any {
        return self
    }
}

extension IntentHandler: SPNoteWidgetIntentHandling {
    func provideNoteOptionsCollection(for intent: SPNoteWidgetIntent, with completion: @escaping (INObjectCollection<SPNote>?, Error?) -> Void) {
        let frc = fetchedResultsController(ofType: Note.self)

        try? frc.performFetch()

        var notes: [SPNote] = []
        if let fetchedObjects = frc.fetchedObjects {
            for object in fetchedObjects {
                let spNote = SPNote(identifier: object.remoteId, display: object.content ?? "New Note")
                notes.append(spNote)
            }
        }

        let collection = INObjectCollection(items: notes)
        completion(collection, nil)
    }
}
