import Intents
import CoreData

class IntentHandler: INExtension {
    override func handler(for intent: INIntent) -> Any {
        return self
    }
}

extension IntentHandler: NoteWidgetIntentHandling {
    func provideNoteOptionsCollection(for intent: NoteWidgetIntent, with completion: @escaping (INObjectCollection<WidgetNote>?, Error?) -> Void) {
        // NOTE: This core data implementation is just to prove that the shared database is accessible and is not intended to be used in production.
        
        let coreDataManager = try? CoreDataManager(StorageSettings().sharedStorageURL)
        coreDataManager?.managedObjectContext.persistentStoreCoordinator = coreDataManager?.persistentStoreCoordinator
        let entityDescription = NSEntityDescription.entity(forEntityName: String(describing: Note.self), in: (coreDataManager?.managedObjectContext)!)
        let fetchRequest = NSFetchRequest<Note>()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Note.simperiumKey, ascending: true)]
        fetchRequest.entity = entityDescription


        let fetchedNotes = try? coreDataManager?.managedObjectContext.fetch(fetchRequest)

        var notes: [WidgetNote] = []

        guard let unwrappedNotes = fetchedNotes else {
            let error = NSError(domain: "Couldn't unwrap", code: 0, userInfo: nil)
            completion(nil, error)
            return
        }

        for fetchedNote in unwrappedNotes {
            let spNote = WidgetNote(identifier: fetchedNote.simperiumKey, display: fetchedNote.content ?? "Untitled Note")
            notes.append(spNote)
        }

        let collection = INObjectCollection(items: notes)
        completion(collection, nil)
    }
}
