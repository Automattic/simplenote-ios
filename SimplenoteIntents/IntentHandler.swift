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
        let sortMode = UserDefaults(suiteName: SimplenoteConstants.sharedGroupDomain)?.integer(forKey: .listSortMode)

        let collection = INObjectCollection(items: notes)
        completion(collection, nil)
    }
}
