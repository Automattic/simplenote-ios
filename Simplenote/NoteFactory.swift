import Foundation

enum NoteFactory {

    static func newNote() -> Note {
        let viewContext = SPAppDelegate.shared().managedObjectContext
        guard let note = NSEntityDescription.insertNewObject(forEntityName: Note.entityName, into: viewContext) as? Note else {
            fatalError()
        }

        note.modificationDate = Date()
        note.creationDate = Date()

        // Set the note's markdown tag according to the global preference (defaults NO for new accounts)
        note.markdown = Options.shared.markdown

        return note
    }
}
