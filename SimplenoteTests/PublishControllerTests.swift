import XCTest
@testable import Simplenote

class PublishControllerTests: XCTestCase {

    private let storage = MockupStorageManager()
    private let timerFactory = MockTimerFactory()
//    private let listenWrapper = PublishListenWrapper()
    private var publishController: PublishController?
    private var mockAppDelegate: MockAppDelegate?

    override func setUpWithError() throws {
        publishController = PublishController(timerFactory: timerFactory, callbackMap: callbackMap)
        if let publishController = publishController {
            mockAppDelegate = MockAppDelegate(publishController: publishController)
        }
    }
    override func setUp() {
//        let publishController = PublishController(timerFactory: timerFactory, callbackMap: callbackMap)
//        let mockAppDelegate = MockAppDelegate(publishController: publishController)
    }

    func testUpdatePublishExitsIfNoChangeInState() {
        let note = storage.insertSampleNote(simperiumKey: TestConstants.simperiumKey)
        note.published = true
        publishController?.updatePublishState(for: note, to: true) { (_) in
            XCTFail("Callback should not be called")
        }

        XCTAssertNil(callbackMap[TestConstants.simperiumKey])
    }

    func testUpdatePublishStateToPublishing() {
        let note = storage.insertSampleNote(simperiumKey: TestConstants.simperiumKey)
        publishController?.updatePublishState(for: note, to: true) { (state) in
            XCTAssertEqual(state, .publishing)
        }
        XCTAssertTrue(note.published)
        XCTAssertEqual(note.publishURL, "")
        XCTAssertNotNil(callbackMap[TestConstants.simperiumKey])
    }

    func testUpdatePublishStateToUnpublishing() {
        let note = storage.insertSampleNote(simperiumKey: TestConstants.simperiumKey)
        publishController?.updatePublishState(for: note, to: false) { (state) in
            XCTAssertEqual(state, .unpublishing)
        }
        XCTAssertFalse(note.published)
        XCTAssertEqual(note.publishURL, "")
        XCTAssertNotNil(callbackMap[TestConstants.simperiumKey])
    }

    func testPublishStateIsChangedToPublishedWhenCalledFromListener() {
        let note = storage.insertSampleNote(simperiumKey: TestConstants.simperiumKey)
        var publishState: PublishState = .unpublished
        publishController?.updatePublishState(for: note, to: true) { (state) in
            publishState = state
        }

        mockAppDelegate?.update(note: note, to: true, with: TestConstants.simperiumKey, with: TestConstants.publishURL)

        XCTAssertEqual(publishState, .published)
    }

    func testPublishStateIsChangedToUnpublishedWhenCalledFromListener() {
        let note = storage.insertSampleNote(simperiumKey: TestConstants.simperiumKey)
        var publishState: PublishState = .published
        publishController?.updatePublishState(for: note, to: true) { (state) in
            publishState = state
        }

        mockAppDelegate?.update(note: note, to: false, with: TestConstants.simperiumKey, with: TestConstants.publishURL)

        XCTAssertEqual(publishState, .unpublished)
    }

    func testTimeoutRemovesStoredCallback() {
        let note = storage.insertSampleNote(simperiumKey: TestConstants.simperiumKey)
        publishController?.updatePublishState(for: note, to: true) { (_) in }

        XCTAssertNotNil(callbackMap[TestConstants.simperiumKey])

        timerFactory.timer?.fire()

        XCTAssertNil(callbackMap[TestConstants.simperiumKey])
    }
}

private struct TestConstants {
    static let simperiumKey = "ABCDEF123456"
    static let publishURL = "ABC123"
}

class MockAppDelegate {
    let publishController: PublishController

    init(publishController: PublishController) {
        self.publishController = publishController
    }

    func update(note: Note, to published: Bool, with key: String, with url: String) {
        note.publishURL = url
        note.published = published
        publishController.didReceiveUpdateFromSimperium(for: key as NSString)
    }
}
