import Foundation

// MARK: - SPObjectManager
//
extension SPObjectManager {

    var managedObjectContext: NSManagedObjectContext {
        return SPAppDelegate.shared().managedObjectContext
    }

    @objc
    func newDefaultNote() -> Note {
        guard let note = NSEntityDescription.insertNewObject(forEntityName: Note.entityName, into: managedObjectContext) as? Note else {
            fatalError()
        }

        note.modificationDate = Date()
        note.creationDate = Date()

        // Set the note's markdown tag according to the global preference (defaults NO for new accounts)
        note.markdown = Options.shared.markdown

        return note
    }

}
