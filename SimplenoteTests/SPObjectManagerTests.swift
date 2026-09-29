import XCTest
@testable import Simplenote

// MARK: - SPObjectManager Tests
//
class SPObjectManagerTests: XCTestCase {

    /// Verifies that new notes get a `simperiumKey` right at creation, so the Internal Link
    /// can be copied before the note is ever saved.
    ///
    /// Ref. https://github.com/Automattic/simplenote-ios/issues/1019
    ///
    func testNewDefaultNoteGetsSimperiumKeyImmediately() {
        let note = SPObjectManager.shared().newDefaultNote()
        defer {
            note.managedObjectContext?.delete(note)
        }

        XCTAssertNotNil(note.simperiumKey)
        XCTAssertNotNil(note.plainInternalLink)
    }
}
