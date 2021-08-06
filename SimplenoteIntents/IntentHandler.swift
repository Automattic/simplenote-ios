import Intents
import CoreData

class IntentHandler: INExtension {
    let coreDataManager: CoreDataManager
    let dataController: WidgetDataController

    override init() {
        do {
            self.coreDataManager = try CoreDataManager(StorageSettings().sharedStorageURL, for: .intents)
            self.dataController = try WidgetDataController(coreDataManager: coreDataManager)
        } catch {
            fatalError()
        }
        super.init()
    }


    override func handler(for intent: INIntent) -> Any {
        return self
    }
}

extension IntentHandler: NoteWidgetIntentHandling {
    func provideNoteOptionsCollection(for intent: NoteWidgetIntent, with completion: @escaping (INObjectCollection<WidgetNote>?, Error?) -> Void) {

        // Fetch notes
        var notes: [Note] = []
        do {
            notes = try dataController.notes()
        } catch {
            completion(nil, error)
        }


        // Return collection to intents
        let collection = widgetNoteInObjectCollection(from: notes)
        completion(collection, nil)
    }

    private func widgetNoteInObjectCollection(from notes: [Note]) -> INObjectCollection<WidgetNote> {
        let widgetNotes = notes.map({ note in
            WidgetNote(identifier: note.simperiumKey, display: note.title)
        })
        return INObjectCollection(items: widgetNotes)
    }
}
