import Foundation
@testable import Simplenote


// MARK: - MockupStorage Sample Entity Insertion Methods
//
extension MockupStorageManager {

    /// Inserts a new (Sample) Note into the receiver's Main MOC
    ///
    @discardableResult
    func insertSampleNote(contents: String = "", simperiumKey: String = "") -> Note {
        guard let note = NSEntityDescription.insertNewObject(forEntityName: Note.entityName, into: viewContext) as? Note else {
            fatalError()
        }

        note.modificationDate = Date()
        note.creationDate = Date()
        note.content = contents
        note.published = false
        note.simperiumKey = simperiumKey

        return note
    }

    /// Inserts a new (Sample) Tag into the receiver's Main MOC
    ///
    @discardableResult
    func insertSampleTag(name: String = "") -> Tag {
        guard let tag = NSEntityDescription.insertNewObject(forEntityName: Tag.entityName, into: viewContext) as? Tag else {
            fatalError()
        }

        tag.name = name

        return tag
    }
}
