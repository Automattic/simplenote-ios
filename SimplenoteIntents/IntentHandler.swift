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
            WidgetNote(identifier: note.simperiumKey, display: note.limitedTitle)
        })
        return INObjectCollection(items: widgetNotes)
    }

    func defaultNote(for intent: NoteWidgetIntent) -> WidgetNote? {
        guard let note = try? dataController.firstNote() else {
            return nil
        }
        return WidgetNote(identifier: note.simperiumKey, display: note.limitedTitle)
    }
}

extension IntentHandler: ListWidgetIntentHandling {
    func provideTagOptionsCollection(for intent: ListWidgetIntent, with completion: @escaping (INObjectCollection<WidgetTag>?, Error?) -> Void) {

        // Prepare data controller for intents
        let dataController: WidgetDataController
        do {
            let coreDataManager = try CoreDataManager(StorageSettings().sharedStorageURL, for: .intents)
            dataController = try WidgetDataController(coreDataManager: coreDataManager)
        } catch {
            completion(nil, error)
            return
        }

        // Fetch Tags
        var tags: [Tag] = []
        do {
            try tags = dataController.tags()
        } catch {
            completion(nil, error)
        }

        // Return collection to intents
        let collection = tagNoteInObjectCollection(from: tags)
        completion(collection, nil)
    }

    private func tagNoteInObjectCollection(from tags: [Tag]) -> INObjectCollection<WidgetTag> {
        let widgetTags = tags.map({ tag in
            WidgetTag(identifier: tag.name ?? "Unamed Tag", display: tag.name ?? "Unamed Tag")
        })
        return INObjectCollection(items: widgetTags)
    }

}
