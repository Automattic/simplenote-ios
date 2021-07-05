import Intents

class IntentHandler: INExtension {
    override func handler(for intent: INIntent) -> Any {
        return self
    }
}

extension IntentHandler: NoteWidgetIntentHandling {
    func provideNoteOptionsCollection(for intent: NoteWidgetIntent, with completion: @escaping (INObjectCollection<SPNote>?, Error?) -> Void) {
        // This is placeholder code to confirm the dynamic intent selection is working
        // TODO: add logic to fetch the available notes for account

        let placeholderNoteData = ["Note 1", "Note 2", "Note 3", "Note 4"]

        var notes: [SPNote] = []

        for placeholder in placeholderNoteData {
            let spNote = SPNote(identifier: placeholder, display: placeholder)
            notes.append(spNote)
        }

        let collection = INObjectCollection(items: notes)
        completion(collection, nil)
    }
}
