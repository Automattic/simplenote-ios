import XCTest
@testable import Simplenote

class PublishControllerTests: XCTestCase {

    private let storage = MockupStorageManager()
    private let timerFactory = MockTimerFactory()
    private let publishFactory = MockPublishListenerFactory()
    private var publishController: PublishController?
    private var mockAppDelegate: MockAppDelegate?

    override func setUpWithError() throws {
        publishController = PublishController(timerFactory: timerFactory, publishListenerFactory: publishFactory)
        if let publishController = publishController {
            mockAppDelegate = MockAppDelegate(publishController: publishController)
        }
    }

    func testUpdatePublishExitsIfNoChangeInState() {
        let note = storage.insertSampleNote(simperiumKey: TestConstants.simperiumKey)
        note.published = true
        publishController?.updatePublishState(for: note, to: true) { (_) in
            XCTFail("Callback should not be called")
        }

        XCTAssertNil(publishFactory.listeners[note.simperiumKey])
    }

    func testUpdatePublishStateToPublishing() {
        let note = storage.insertSampleNote(simperiumKey: TestConstants.simperiumKey)
        publishController?.updatePublishState(for: note, to: true) { (state) in
            XCTAssertEqual(state, .publishing)
        }
        XCTAssertTrue(note.published)
        XCTAssertEqual(note.publishURL, "")
        XCTAssertNotNil(publishFactory.listeners[TestConstants.simperiumKey])
    }

    func testUpdatePublishStateToUnpublishing() {
        let note = storage.insertSampleNote(simperiumKey: TestConstants.simperiumKey, published: true)
        publishController?.updatePublishState(for: note, to: false) { (state) in
            XCTAssertEqual(state, .unpublishing)
        }
        XCTAssertFalse(note.published)
        XCTAssertEqual(note.publishURL, "")
        XCTAssertNotNil(publishFactory.listeners[TestConstants.simperiumKey])
    }

    func testPublishStateIsChangedToPublishedWhenCalledFromListener() {
        let note = storage.insertSampleNote(simperiumKey: TestConstants.simperiumKey)
        var publishState: PublishState = .unpublished
        publishController?.updatePublishState(for: note, to: true) { (state) in
            publishState = state
        }

        mockAppDelegate?.updateNote(note: note, published: true, withKey: TestConstants.simperiumKey, withURL: TestConstants.publishURL)

        XCTAssertEqual(publishState, .published)
    }

    func testPublishStateIsChangedToUnpublishedWhenCalledFromListener() {
        let note = storage.insertSampleNote(simperiumKey: TestConstants.simperiumKey)
        var publishState: PublishState = .published
        publishController?.updatePublishState(for: note, to: true) { (state) in
            publishState = state
        }

        mockAppDelegate?.updateNote(note: note, published: false, withKey: TestConstants.simperiumKey, withURL: TestConstants.publishURL)

        XCTAssertEqual(publishState, .unpublished)
    }

    func testControllerDoesNotChangeIfUpdateIsCalledOnItemNotBeingObserved() {
        let note = storage.insertSampleNote(simperiumKey: TestConstants.simperiumKey)
        let noteB = storage.insertSampleNote(simperiumKey: TestConstants.secondKey)
        var publishState: PublishState = .unpublished
        publishController?.updatePublishState(for: note, to: true) { (state) in
            XCTAssertEqual(state, .publishing)
            publishState = state
        }

        mockAppDelegate?.updateNote(note: noteB, published: true, withKey: TestConstants.secondKey, withURL: TestConstants.publishURL)

        XCTAssertEqual(publishState, .publishing)
    }
}

private struct TestConstants {
    static let simperiumKey = "ABCDEF123456"
    static let secondKey = "QWFPGJL4567890"
    static let publishURL = "ABC123"
}

class MockAppDelegate {
    let publishController: PublishController

    init(publishController: PublishController) {
        self.publishController = publishController
    }

    func updateNote(note: Note, published: Bool, withKey key: String, withURL url: String) {
        note.publishURL = url
        note.published = published
        publishController.didReceiveUpdateFromSimperium(for: key)
    }
}

class MockPublishListenerFactory: PublishListenerFactory {
    var listeners = [String: PublishListenWrapper]()

    override func publishListenerWrapper(note: Note, block: @escaping (PublishState) -> Void, expiration: Date) -> PublishListenWrapper {
        let newWrapper = PublishListenWrapper(note: note, block: block, expiration: expiration)
        listeners[note.simperiumKey] = newWrapper
        return newWrapper
    }
}
