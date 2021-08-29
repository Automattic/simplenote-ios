import Intents
import CoreData

class IntentHandler: INExtension {
    let coreDataManager: CoreDataManager
    let widgetResultsController: WidgetResultsController

    override init() {
        do {
            self.coreDataManager = try CoreDataManager(StorageSettings().sharedStorageURL, for: .intents)
            self.widgetResultsController = WidgetResultsController(context: coreDataManager.managedObjectContext)
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
        guard WidgetDefaults.shared.loggedIn else {
            completion(nil, WidgetError.appConfigurationError)
            return
        }

        guard let notes = widgetResultsController.notes() else {
            completion(nil, WidgetError.fetchError)
            return
        }

        let collection = widgetNoteInObjectCollection(from: notes)
        completion(collection, nil)
    }

    private func widgetNoteInObjectCollection(from notes: [Note]) -> INObjectCollection<WidgetNote> {
        let widgetNotes = notes.map({ note in
            WidgetNote(identifier: note.simperiumKey, display: note.title)
        })
        return INObjectCollection(items: widgetNotes)
    }

    func defaultNote(for intent: NoteWidgetIntent) -> WidgetNote? {
        guard WidgetDefaults.shared.loggedIn,
              let note = widgetResultsController.firstNote() else {
            return nil
        }

        return WidgetNote(identifier: note.simperiumKey, display: note.title)
    }
}

extension IntentHandler: ListWidgetIntentHandling {
    func provideTagOptionsCollection(for intent: ListWidgetIntent, with completion: @escaping (INObjectCollection<WidgetTag>?, Error?) -> Void) {
        guard WidgetDefaults.shared.loggedIn else {
            completion(nil, WidgetError.appConfigurationError)
            return
        }

        guard let tags = widgetResultsController.tags() else {
            completion(nil, WidgetError.fetchError)
            return
        }

        // Return collection to intents
        let collection = tagNoteInObjectCollection(from: tags)
        completion(collection, nil)
    }

    private func tagNoteInObjectCollection(from tags: [Tag]) -> INObjectCollection<WidgetTag> {
        var items = [WidgetTag(kind: .allNotes)]

        tags.forEach { tag in
            let tag = WidgetTag(kind: .tag, name: tag.name)
            tag.kind = .tag
            items.append(tag)
        }

        return INObjectCollection(items: items)
    }

    func defaultTag(for intent: ListWidgetIntent) -> WidgetTag? {
        WidgetTag(kind: .allNotes)
    }
}
