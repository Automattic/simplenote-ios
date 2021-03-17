import XCTest
@testable import Simplenote

class NoticeControllerTests: XCTestCase {
    private lazy var presenter = MockNoticePresenter()
    private lazy var timerFactory = MockTimerFactory()
    private lazy var controller = NoticeController(presenter: presenter, timerFactory: timerFactory)

    func testSetupNoticeContoller() {
        controller.setupNoticeController()

        XCTAssertTrue(presenter.listeningToKeyboard == true)
    }

    func testPresentNotice() {
        let notice = Notice(message: "Message", action: nil)
        let expectedActions: [MockNoticePresenter.Action] = [
            .present(notice.message)
        ]
        controller.present(notice)

        XCTAssertEqual(expectedActions, presenter.actionLog)
        XCTAssertEqual(presenter.lastNoticeView?.message, notice.message)
    }

    func testControlDoesNotPresentNewNoticeIfPresenting() {
        let noticeA = Notice(message: "Message A", action: nil)
        let noticeB = Notice(message: "Message B", action: nil)
        let expectedActions: [MockNoticePresenter.Action] = [
            .present(noticeA.message)
        ]

        controller.present(noticeA)
        controller.present(noticeB)

        XCTAssertEqual(expectedActions, presenter.actionLog)
        XCTAssertEqual(presenter.lastNoticeView?.message, noticeA.message)
    }

    func testAppendToQueueIfNew() {
        let noticeA = Notice(message: "Message A", action: nil)
        let noticeB = Notice(message: "Message B", action: nil)

        controller.present(noticeA)
        XCTAssertEqual(controller.pendingNotices, 0)

        controller.present(noticeA)
        XCTAssertEqual(controller.pendingNotices, 0)

        controller.present(noticeB)
        XCTAssertEqual(controller.pendingNotices, 1)

        controller.present(noticeB)
        XCTAssertEqual(controller.pendingNotices, 1)
    }

    func testMakeNoticeView() throws {
        let notice = Notice(message: "Message", action: nil)

        controller.present(notice)

        XCTAssertEqual(notice.message, presenter.lastNoticeView?.message)
        XCTAssertNil(presenter.lastNoticeView?.handler)
    }

    func testMakeNoticeViewWithAction() {
        let action = NoticeAction(title: "Title") {
            print("Action")
        }
        let notice = Notice(message: "Message ", action: action)

        controller.present(notice)

        XCTAssertEqual(notice.message, presenter.lastNoticeView?.message)
        XCTAssertEqual(notice.action?.title, presenter.lastNoticeView?.actionTitle)
        XCTAssertNotNil(presenter.lastNoticeView?.handler)
    }

    func testMakeNoticeViewWithEmptyNotice() {
        let action = NoticeAction(title: "") { }
        let notice = Notice(message: "", action: action)

        controller.present(notice)

        XCTAssertEqual(notice.message, presenter.lastNoticeView?.message)
        XCTAssertNotEqual(notice.action?.title, presenter.lastNoticeView?.actionTitle)
        XCTAssertNotNil(presenter.lastNoticeView?.handler)
    }

    func testDismiss() {
        let noticeA = Notice(message: "Message A", action: nil)

        controller.present(noticeA)

        controller.dismiss()

//        XCTAssertTrue(presenter.dismissed)
        XCTAssertFalse(controller.isPresenting)
    }

    func testDismissContinuesToNextNotice() {
        let noticeA = Notice(message: "Message A", action: nil)
        let noticeB = Notice(message: "Message B", action: nil)
        controller.present(noticeA)
        controller.present(noticeB)

        var expectedActions: [MockNoticePresenter.Action] = [
            .present(noticeA.message)
        ]
        XCTAssertEqual(presenter.actionLog, expectedActions)

        timerFactory.timer?.fire()

        expectedActions.append(.dismiss(noticeA.message))
        expectedActions.append(.present(noticeB.message))
        XCTAssertEqual(presenter.actionLog, expectedActions)

        timerFactory.timer?.fire()

        expectedActions.append(.dismiss(noticeB.message))
        XCTAssertEqual(presenter.actionLog, expectedActions)
    }
}

extension NoticeControllerTests {
    static var timeInterval = TimeInterval.zero
    static var timerNoActionCompletionHandler: (Timer) -> Void = { (_) in }
}

class MockNoticePresenter: NoticePresenter {
    enum Action: Equatable {
        case present(String?)
        case dismiss(String?)
    }

    var actionLog: [Action] = []

    var listeningToKeyboard: Bool = false
    var lastNoticeView: NoticeView?

    override func presentNoticeView(_ noticeView: NoticeView, completion: @escaping () -> Void) {
        lastNoticeView = noticeView
        actionLog.append(.present(noticeView.message))
        completion()
    }

    override func dismissNotification(completion: @escaping () -> Void) {
        let noticeView = try! XCTUnwrap(lastNoticeView)
        lastNoticeView = nil
        actionLog.append(.dismiss(noticeView.message))
        completion()
    }

    override func startListeningToKeyboardNotifications() {
        listeningToKeyboard = true
    }
}

class MockTimerFactory: TimerFactory {
    var timer: Timer?

    override func scheduledTimer(with timeInterval: TimeInterval, completion: @escaping () -> Void) -> Timer {
        let timer = MockTimer()
        timer.completion = completion
        return timer
    }
}

class MockTimer: Timer {
    var completion: (() -> Void)?

    override func fire() {
        completion?()
    }

    override func invalidate() {
        completion = nil
    }
}
