import XCTest
@testable import Simplenote


// MARK: - Note+Extension Tests
//
class NoteLinkTests: XCTestCase {

    /// InMemory Storage!
    ///
    private let storage = MockupStorageManager()

    func testNoteInterlinkReferenceCount() {
        let (referencedNote, referencing) = insertSampleEntitiesWithInterlinkReferences()
        let noReference = referencing[0]
        let oneReference = referencing[1]
        let twoReference = referencing[2]
        let emptyContent = referencing[3]

        XCTAssertEqual(noReference.instancesOfReference(to: referencedNote), 0)
        XCTAssertEqual(oneReference.instancesOfReference(to: referencedNote), 1)
        XCTAssertEqual(twoReference.instancesOfReference(to: referencedNote), 2)
        XCTAssertEqual(emptyContent.instancesOfReference(to: referencedNote), 0)
    }
}

// MARK: - Private
//
private extension NoteLinkTests {

    /// Inserts a collection of sample entities.
    ///
    func insertSampleEntitiesWithInterlinkReferences() -> (referenced: Note, samles: Array<Note>) {
        let referencedNote = storage.insertSampleNote(contents: "This note will be referenced to")
        var notesReferencing = Array<Note>()

        if let link = referencedNote.plainInternalLink {
            notesReferencing.append(storage.insertSampleNote(contents: "Does not contain reference"))
            notesReferencing.append(storage.insertSampleNote(contents: "This note contains one reference to note \(link)"))
            notesReferencing.append(storage.insertSampleNote(contents: "This note contains two reference \(link) to note \(link)"))
            notesReferencing.append(storage.insertSampleNote(contents: ""))
        }

        storage.save()

        return (referencedNote, notesReferencing)
    }
}
