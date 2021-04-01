import XCTest
@testable import Simplenote

class PublishControllerTests: XCTestCase {
    private let publishController = PublishController()
    private let storage = MockupStorageManager()
    private var logger = PublishLogger()
    private var mockAppDelegate: MockAppDelegate?

    override func setUpWithError() throws {
        publishController.onUpdate = { note in
            self.logger.lastUpdateNote = note
            self.logger.actions.append(note.publishState)
        }

        mockAppDelegate = MockAppDelegate(publishController: publishController)
    }

    func testUpdatePublishStateExitsIfStateUnchanged() {
        let note = storage.insertSampleNote(published: true)

        publishController.updatePublishState(for: note, to: true)

        XCTAssertTrue(logger.actions.isEmpty)
        XCTAssertNil(logger.lastUpdateNote)
    }

    func testUpdatePublishStateSetsNoteStateToPublished() {
        let note = storage.insertSampleNote(published: false)

        publishController.updatePublishState(for: note, to: true)

        let expectedActions: [PublishState] = [.publishing]

        XCTAssertTrue(note.published)
        testExpectations(with: note, expectedActions: expectedActions)
    }

    func testUpdatePublishStateSetsNoteStateToUnpublished() {
        let note = storage.insertSampleNote(published: true, publishURL: TestConstants.publishURL)

        publishController.updatePublishState(for: note, to: false)

        let expectedActions: [PublishState] = [.unpublishing]

        XCTAssertFalse(note.published)
        testExpectations(with: note, expectedActions: expectedActions)
    }

    func testDidReceiveUpdateNotificationUpdatesPublishState() {
        let note = storage.insertSampleNote(simperiumKey: TestConstants.simperiumKey, published: false)
        publishController.updatePublishState(for: note, to: true)
        var expectedActions: [PublishState] = [.publishing]

        mockAppDelegate?.updateNotification(for: note, withURL: TestConstants.publishURL)
        expectedActions.append(.published)

        testExpectations(with: note, expectedActions: expectedActions)
    }

    func testDidReceiveUpdateIgnoresNonObservedUpdates() {
        let note = storage.insertSampleNote(simperiumKey: TestConstants.simperiumKey)
        let noteB = storage.insertSampleNote(simperiumKey: TestConstants.altSimperiumKey)

        mockAppDelegate?.updateNotification(for: note, withURL: TestConstants.publishURL)
        mockAppDelegate?.updateNotification(for: noteB, withURL: TestConstants.publishURL, observedProperty: TestConstants.altObservedProperty)

        XCTAssertNil(logger.lastUpdateNote)
        XCTAssertTrue(logger.actions.isEmpty)
    }

    func testListenerRemovedAfterDidReceiUpdateCalled() {
        let note = storage.insertSampleNote(simperiumKey: TestConstants.simperiumKey)
        publishController.updatePublishState(for: note, to: true)
        var expectedActions: [PublishState] = [.publishing]

        mockAppDelegate?.updateNotification(for: note, withURL: TestConstants.publishURL)
        expectedActions.append(.published)

        mockAppDelegate?.updateNotification(for: note, withURL: TestConstants.removeURL)

        testExpectations(with: note, expectedActions: expectedActions)
    }

    func testDidReceiveDeleteNotificationRemovesListener() {
        let note = storage.insertSampleNote(simperiumKey: TestConstants.simperiumKey)
        publishController.updatePublishState(for: note, to: true)
        let expectedActions: [PublishState] = [.publishing]

        mockAppDelegate?.deleteNotification(for: note)

        mockAppDelegate?.updateNotification(for: note, withURL: TestConstants.removeURL)

        testExpectations(with: note, expectedActions: expectedActions)
    }

    func testDidReceiveDeleteNotificationIgnoredWithUnobservedKey() {
        let note = storage.insertSampleNote(simperiumKey: TestConstants.simperiumKey)
        let noteB = storage.insertSampleNote(simperiumKey: TestConstants.altSimperiumKey)

        publishController.updatePublishState(for: note, to: true)
        var expectedActions: [PublishState] = [.publishing]
        mockAppDelegate?.deleteNotification(for: noteB)

        mockAppDelegate?.updateNotification(for: note, withURL: TestConstants.publishURL)
        expectedActions.append(.published)

        testExpectations(with: note, expectedActions: expectedActions)
    }

    private func testExpectations(with note: Note, expectedActions: [PublishState]) {
        XCTAssertEqual(note, logger.lastUpdateNote)
        XCTAssertEqual(expectedActions, logger.actions)
    }
}

private struct TestConstants {
    static let publishURL = "abc123"
    static let removeURL = ""
    static let simperiumKey = "qwfpgj123456"
    static let altSimperiumKey = "abcdef67890"
    static let observedProperty = "publishURL"
    static let altObservedProperty = "content"
}

private class PublishLogger {
    var lastUpdateNote: Note?
    var actions = [PublishState]()
}

private class MockAppDelegate {
    let publishController: PublishController

    init(publishController: PublishController) {
        self.publishController = publishController
    }

    func updateNotification(for note: Note, withURL url: String, observedProperty: String = TestConstants.observedProperty) {
        note.publishURL = url
        publishController.didReceiveUpdateNotification(for: note.simperiumKey, with: [observedProperty])
    }

    func deleteNotification(for note: Note) {
        publishController.didReceiveDeleteNotification(for: note.simperiumKey)
    }
}
