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
        return self
    }
}

extension IntentHandler: NoteWidgetIntentHandling {
    func provideNoteOptionsCollection(for intent: NoteWidgetIntent, with completion: @escaping (INObjectCollection<WidgetNote>?, Error?) -> Void) {
        guard let dataController = try? WidgetDataController(context: coreDataManager.managedObjectContext) else {
            completion(nil, WidgetError.appConfigurationError)
            return
        }

        guard let notes = dataController.notes() else {
            completion(nil, WidgetError.fetchError)
            return
        }

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
        guard let note = try? WidgetDataController(context: coreDataManager.managedObjectContext).firstNote() else {
            return nil
        }

        return WidgetNote(identifier: note.simperiumKey, display: note.limitedTitle)
    }
}

extension IntentHandler: ListWidgetIntentHandling {
    func provideTagOptionsCollection(for intent: ListWidgetIntent, with completion: @escaping (INObjectCollection<WidgetTag>?, Error?) -> Void) {
        guard let dataController = try? WidgetDataController(context: coreDataManager.managedObjectContext) else {
            completion(nil, WidgetError.appConfigurationError)
            return
        }

        guard let tags = dataController.tags() else {
            completion(nil, WidgetError.fetchError)
            return
        }

        // Return collection to intents
        let collection = tagNoteInObjectCollection(from: tags)
        completion(collection, nil)
    }

    private func tagNoteInObjectCollection(from tags: [Tag]) -> INObjectCollection<WidgetTag> {
        let allNotesWidgetTag: [WidgetTag] = [WidgetTag(identifier: WidgetConstants.allNotesIdentifier, display: Constants.allNotesDisplay)]
        let fetchedWidgetTags = tags.map({ tag in
            WidgetTag(identifier: tag.name ?? Constants.unnamedTag, display: tag.name ?? Constants.unnamedTag)
        })
        return INObjectCollection(items: allNotesWidgetTag + fetchedWidgetTags)
    }

    func defaultTag(for intent: ListWidgetIntent) -> WidgetTag? {
        WidgetTag(identifier: WidgetConstants.allNotesIdentifier, display: Constants.allNotesDisplay)
    }
}

private struct Constants {
    static let allNotesDisplay = NSLocalizedString("All Notes", comment: "Display title for All Notes")
    static let unnamedTag = NSLocalizedString("Unnamed Tag", comment: "Default title for an unnamed tag")
}
