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
        guard let notes = try? WidgetDataController(coreDataManager: coreDataManager).notes() else {
            completion(nil, WidgetError.appConfigurationError)
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

extension IntentHandler: ListWidgetIntentHandling {
    func provideTagOptionsCollection(for intent: ListWidgetIntent, with completion: @escaping (INObjectCollection<WidgetTag>?, Error?) -> Void) {
        guard let tags = try? WidgetDataController(coreDataManager: coreDataManager).tags() else {
            completion(nil, WidgetError.appConfigurationError)
            return
        }

        // Return collection to intents
        let collection = tagNoteInObjectCollection(from: tags)
        completion(collection, nil)
    }

    private func tagNoteInObjectCollection(from tags: [Tag]) -> INObjectCollection<WidgetTag> {
        let allNotesWidgetTag: [WidgetTag] = [WidgetTag(identifier: WidgetConstants.allNotesIdentifier, display: Constants.allNotesDisplay)]
        let fetchedWidgetTags = tags.map({ tag in
            WidgetTag(identifier: tag.name ?? "Unamed Tag", display: tag.name ?? "Unamed Tag")
        })
        return INObjectCollection(items: allNotesWidgetTag + fetchedWidgetTags)
    }

    func defaultTag(for intent: ListWidgetIntent) -> WidgetTag? {
        WidgetTag(identifier: WidgetConstants.allNotesIdentifier, display: Constants.allNotesDisplay)
    }
}

private struct Constants {
    static let allNotesDisplay = "All Notes"
}
