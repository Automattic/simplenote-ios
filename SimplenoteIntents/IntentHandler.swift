import Intents
import CoreData

class IntentHandler: INExtension {
    override func handler(for intent: INIntent) -> Any {

        switch intent {
        case is NoteWidgetIntent:
            return NoteWidgetIntentHandler()
        case is ListWidgetIntent:
            return ListWidgetIntentHandler()
        default:
            return self
        }
    }
}
