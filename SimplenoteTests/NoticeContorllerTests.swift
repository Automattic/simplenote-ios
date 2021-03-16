import XCTest
@testable import Simplenote

class NoticeContorllerTests: XCTestCase {
    private lazy var presenter = MockNoticePresenter()
    private lazy var timerFactory = MockTimerFactory()
    private lazy var controller = NoticeController(presenter: presenter, timerFactory: timerFactory)

    func testSetupNoticeContoller() {
        controller.setupNoticeController()

        XCTAssertTrue(presenter.listeningToKeyboard == true)
    }

    func testPresentNotice() throws {
        let notice = Notice(message: "Message", action: nil)

        controller.present(notice)

        XCTAssertTrue(presenter.presented)
    }

    func testControlDoesNotPresentNewNoticeIfPresenting() throws {
        let noticeA = Notice(message: "Message A", action: nil)
        let noticeB = Notice(message: "Message B", action: nil)
        controller.present(noticeA)
        controller.present(noticeB)

        XCTAssertTrue(presenter.presented)
        XCTAssertEqual(presenter.presentedViews.count, 1)
        XCTAssertEqual(controller.pendingNotices, 1)
        let presentedNotice = try XCTUnwrap(presenter.noticeView as? NoticeView)
        XCTAssertEqual(presentedNotice.message, noticeA.message)
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

        let view = try XCTUnwrap(presenter.noticeView as? NoticeView)
        XCTAssertEqual(notice.message, view.message)
        XCTAssertNil(view.handler)
    }

    func testMakeNoticeViewWithAction() throws {
        let action = NoticeAction(title: "Title") {
            print("Action")
        }
        let notice = Notice(message: "Message ", action: action)

        controller.present(notice)

        let view = try XCTUnwrap(presenter.noticeView as? NoticeView)
        XCTAssertEqual(notice.message, view.message)
        XCTAssertEqual(notice.action?.title, view.actionTitle)
        XCTAssertNotNil(view.handler)
    }

    func testMakeNoticeViewWithEmptyNotice() throws {
        let action = NoticeAction(title: "") {
            //No action
        }
        let notice = Notice(message: "", action: action)

        controller.present(notice)

        let view = try XCTUnwrap(presenter.noticeView as? NoticeView)
        XCTAssertEqual(notice.message, view.message)
        XCTAssertNotEqual(notice.action?.title, view.actionTitle)
        XCTAssertNotNil(view.handler)
    }

    func testDismiss() {
        let noticeA = Notice(message: "Message A", action: nil)

        controller.present(noticeA)

        controller.dismiss()

        XCTAssertTrue(presenter.dismissed)
        XCTAssertFalse(controller.isPresenting)
    }

    func testDismissContinuesToNextNotice() {
        let noticeA = Notice(message: "Message A", action: nil)
        let noticeB = Notice(message: "Message B", action: nil)
        controller.present(noticeA)
        controller.present(noticeB)

        XCTAssertTrue(controller.isPresenting)
        XCTAssertEqual(controller.pendingNotices, 1)

        controller.dismiss()

        XCTAssertTrue(controller.isPresenting)
        XCTAssertEqual(controller.pendingNotices, 0)

        controller.dismiss()

        XCTAssertTrue(presenter.dismissed)
        XCTAssertFalse(controller.isPresenting)
        XCTAssertEqual(controller.pendingNotices, 0)
        XCTAssertEqual(presenter.actionLog, "presentNoticeView(Message A), dismissNotification(), presentNoticeView(Message B), dismissNotification(), ")
    }
}

extension NoticeContorllerTests {
    static var timeInterval = TimeInterval.zero
    static var timerNoActionCompletionHandler: (Timer) -> Void = { (_) in
        //no action
    }
}

class MockNoticePresenter: NoticePresenter {
    var presented: Bool = false
    var dismissed: Bool = false
    var listeningToKeyboard: Bool = false
    var presentedViews = [NoticeView]()
    var actionLog = String()

    override func presentNoticeView(_ noticeView: NoticeView, completion: @escaping () -> Void) {
        self.noticeView = noticeView
        presentedViews.append(noticeView)
        actionLog.append("presentNoticeView(\(noticeView.message ?? "")), ")
        presented = true

        completion()
    }

    override func dismissNotification(completion: @escaping () -> Void) {
        dismissed = true
        actionLog.append("dismissNotification(), ")
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
