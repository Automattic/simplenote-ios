import XCTest
@testable import Simplenote

private let storage = MockupStorageManager()
private let publishController = PublishController()
private let mockAppDelegate = MockAppDelegate(publishController: publishController)
private let callbackMap = [String: PublishListenWrapper]()

class PublishControllerTests: XCTestCase {

    func testUpdatePublishExitsIfNoChangeInState() {
        let note = storage.insertSampleNote(simperiumKey: TestConstants.simperiumKey)

        publishController.updatePublishState(for: note, to: false) { (_) in
            XCTFail("Callback should not be called")
        }

        XCTAssertFalse(note.published)
    }

    func testUpdatePublishStateToPublishing() {
        let note = storage.insertSampleNote(simperiumKey: TestConstants.simperiumKey)
        publishController.updatePublishState(for: note, to: true) { (state) in
            XCTAssertEqual(state, .publishing)
        }
        XCTAssertTrue(note.published)
        XCTAssertEqual(note.publishURL, "")
    }

    func testUpdatePublishStateToUnpublishing() {
        let note = storage.insertSampleNote(simperiumKey: TestConstants.simperiumKey)
        publishController.updatePublishState(for: note, to: false) { (state) in
            XCTAssertEqual(state, .unpublishing)
        }
        XCTAssertFalse(note.published)
        XCTAssertEqual(note.publishURL, "")
    }

    func testPublishStateIsChangedToPublishedWhenCalledFromListener() {
        let note = storage.insertSampleNote(simperiumKey: TestConstants.simperiumKey)
        var publishState: PublishState = .unpublished
        publishController.updatePublishState(for: note, to: true) { (state) in
            publishState = state
        }

        mockAppDelegate.update(note: note, to: true, with: TestConstants.simperiumKey, with: "ABC123")

        XCTAssertEqual(publishState, .published)
    }

    func testPublishStateIsChangedToUnpublishedWhenCalledFromListener() {
        let note = storage.insertSampleNote(simperiumKey: TestConstants.simperiumKey)
        var publishState: PublishState = .unpublished
        publishController.updatePublishState(for: note, to: true) { (state) in
            publishState = state
        }

        mockAppDelegate.update(note: note, to: false, with: TestConstants.simperiumKey, with: "ABC123")

        XCTAssertEqual(publishState, .unpublished)
    }
}

private struct TestConstants {
    static let simperiumKey = "ABCDEF123456"
}

class MockAppDelegate {
    let publishController: PublishController

    init(publishController: PublishController) {
        self.publishController = publishController
    }

    func update(note: Note, to published: Bool, with key: String, with url: String) {
        note.publishURL = "ABC123"
        note.published = published
        publishController.didReceiveUpdateFromSimperium(for: key as NSString)
    }
}
