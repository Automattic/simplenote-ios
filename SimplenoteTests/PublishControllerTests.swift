import XCTest
@testable import Simplenote

private let storage = MockupStorageManager()
private let publishController = PublishController()
private var note: Note = storage.insertSampleNote()

class PublishControllerTests: XCTestCase {

    override func setUp() {
        note.simperiumKey = "ABCDEF123456"
    }

    func testUpdatePublishExitsIfNoChangeInState() {
        publishController.updatePublishState(for: note, to: false) { (_) in
            XCTFail("Callback should not be called")
        }

        XCTAssertFalse(note.published)
    }

    func testUpdatePublishStateToPublishing() {
        publishController.updatePublishState(for: note, to: true) { (state) in
            XCTAssertEqual(state, .publishing)
        }
        XCTAssertTrue(note.published)
        XCTAssertEqual(note.publishURL, "")
    }

    func testUpdatePublishStateToUnpublishing() {
        publishController.updatePublishState(for: note, to: false) { (state) in
            XCTAssertEqual(state, .unpublishing)
        }
        XCTAssertFalse(note.published)
        XCTAssertEqual(note.publishURL, "")
    }
}

