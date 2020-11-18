import Foundation
import SimplenoteFoundation

// MARK: - SPObjectManager
//
extension SPObjectManager {

    /// Returns the most recently modified note (not deleted)
    ///
    var recentlyModifiedNote: Note? {
        let predicate = NSPredicate.predicateForNotes(deleted: false)
        let sortDescriptor = NSSortDescriptor(keyPath: \Note.modificationDate, ascending: false)

        let request = NSFetchRequest<Note>(entityName: Note.entityName)
        request.predicate = predicate
        request.sortDescriptors = [sortDescriptor]
        request.fetchLimit = 1

        let results = try? SPAppDelegate.shared().managedObjectContext.fetch(request)

        return results?.first
    }

}
