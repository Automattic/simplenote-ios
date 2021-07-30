import Intents
import CoreData

class IntentHandler: INExtension {
    override func handler(for intent: INIntent) -> Any {
        return self
    }
}

extension IntentHandler: NoteWidgetIntentHandling {
    func provideNoteOptionsCollection(for intent: NoteWidgetIntent, with completion: @escaping (INObjectCollection<WidgetNote>?, Error?) -> Void) {
        var notes: [WidgetNote] = []

        // TODO: add intent core data implementation.
        // NOTE: This core data implementation is just to prove that the shared database is accessible and is not intended to be used in production.
        let dataController: WidgetDataController

        do {
            dataController = try WidgetDataController()
        } catch {
            completion(nil, error)
            return
        }

        let fetchedNotes = dataController.notes()

        for fetchedNote in fetchedNotes {
            var display = fetchedNote.content ?? "Untitled Note"
            if display.count < 1 {
                display = "Untitled Note"
            }

            let spNote = WidgetNote(identifier: fetchedNote.simperiumKey, display: display)
            notes.append(spNote)
        }
        let collection = INObjectCollection(items: notes)
        completion(collection, nil)
    }
}
