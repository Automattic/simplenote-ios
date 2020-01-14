import Foundation
@testable import Simplenote


// MARK: - MockupStorage Sample Entity Insertion Methods
//
extension MockupStorageManager {

    /// Inserts a new (Sample) Note into the specified context.
    ///
    @discardableResult
    func insertSampleNote() -> Note {
        guard let note = NSEntityDescription.insertNewObject(forEntityName: Note.entityName, into: viewContext) as? Note else {
            fatalError()
        }

        note.modificationDate = Date()
        note.creationDate = Date()

        return note
    }
}
