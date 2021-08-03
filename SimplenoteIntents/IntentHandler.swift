import Intents
import CoreData

class IntentHandler: INExtension {
    override func handler(for intent: INIntent) -> Any {
        return self
    }
}

extension IntentHandler: NoteWidgetIntentHandling {
    func provideNoteOptionsCollection(for intent: NoteWidgetIntent, with completion: @escaping (INObjectCollection<WidgetNote>?, Error?) -> Void) {

        // Prepare data controller for intents
        let dataController: WidgetDataController
        do {
            let coreDataManager = try CoreDataManager(StorageSettings().sharedStorageURL, for: .intents)
            dataController = try WidgetDataController(coreDataManager: coreDataManager)
        } catch {
            completion(nil, error)
            return
        }

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
        var widgetNotes: [WidgetNote] = []
        for note in notes {
            let spNote = WidgetNote(identifier: note.simperiumKey, display: note.title)
            widgetNotes.append(spNote)
        }
        return INObjectCollection(items: widgetNotes)
    }
}
