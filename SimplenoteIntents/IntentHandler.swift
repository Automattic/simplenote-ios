import Intents
import CoreData

class IntentHandler: INExtension {
    let coreDataManager: CoreDataManager

    override init() {
        do {
            self.coreDataManager = try CoreDataManager(StorageSettings().sharedStorageURL, for: .intents)
        } catch {
            fatalError()
        }
        super.init()
    }


    override func handler(for intent: INIntent) -> Any {
        NSLog("failed to return handler")
        return self
    }
}

extension IntentHandler: NoteWidgetIntentHandling {
    func provideNoteOptionsCollection(for intent: NoteWidgetIntent, with completion: @escaping (INObjectCollection<WidgetNote>?, Error?) -> Void) {
        NSLog("attempting to provied note options collection")
        guard let dataController = try? WidgetDataController(coreDataManager: coreDataManager) else {
            completion(nil, WidgetError.appConfigurationError)
            return
        }
        // Fetch notes
        var notes: [Note] = []
        do {
            notes = try dataController.notes()
        } catch {
            NSLog("Could not supply notes: %@", error.localizedDescription)
            completion(nil, error)
            return
        }


        // Return collection to intents
        let collection = widgetNoteInObjectCollection(from: notes)
        completion(collection, nil)
    }

    private func widgetNoteInObjectCollection(from notes: [Note]) -> INObjectCollection<WidgetNote> {
        let widgetNotes = notes.map({ note in
            WidgetNote(identifier: note.simperiumKey, display: note.limitedTitle)
        })
        return INObjectCollection(items: widgetNotes)
    }

    func defaultNote(for intent: NoteWidgetIntent) -> WidgetNote? {
        guard let dataController = try? WidgetDataController(coreDataManager: coreDataManager) else {
            return nil
        }

        guard let note = try? dataController.firstNote() else {
            return nil
        }
        return WidgetNote(identifier: note.simperiumKey, display: note.limitedTitle)
    }
}
