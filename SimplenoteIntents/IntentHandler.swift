import Intents
import CoreData

class IntentHandler: INExtension {
    override func handler(for intent: INIntent) -> Any {

        switch intent {
        case is NoteWidgetIntent:
            return NoteWidgetIntentHandler()
        case is ListWidgetIntent:
            return ListWidgetIntentHandler()
        case is OpenNewNoteIntent:
            return OpenNewNoteIntentHandler()
        case is OpenNoteIntent:
            return OpenNoteIntentHandler()
        case is AppendNoteIntent:
            return AppendNoteIntentHandler()
        case is CreateNewNoteIntent:
            return CreateNewNoteIntentHandler()
        case is FindNoteIntent:
            return FindNoteIntentHandler()
        case is CopyNoteContentIntent:
            return CopyNoteContentIntentHandler()
        case is FindNoteWithTagIntent:
            return FindNoteWithTagIntentHandler()
        default:
            return self
        }
    }
}
