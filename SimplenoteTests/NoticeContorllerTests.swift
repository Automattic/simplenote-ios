import XCTest
@testable import Simplenote

class NoticeContorllerTests: XCTestCase {
    private lazy var presenter = MockNoticePresenter()
    private lazy var timerFactory = MockTimerFactory()
    private lazy var controller = NoticeController(presenter: presenter, timerFactor: timerFactory)

    func testSetupNoticeContoller() {
        controller.setupNoticeController()

        XCTAssertTrue(presenter.listeningToKeyboard == true)
    }

    func testPresentNotice() throws {
        let notice = Notice(message: "Message", action: nil)
        controller.present(notice)

        XCTAssertTrue(presenter.presented)

        let presentedNoticeView = try XCTUnwrap(presenter.noticeView as? NoticeView)
        XCTAssertEqual(presentedNoticeView.message, notice.message)
        XCTAssertTrue(presentedNoticeView.handler == nil)
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

    func testControllerPresent() {
        let expectation = XCTestExpectation(description: "Did dismiss notice")
        timerFactory.timer = Timer(timeInterval: TimeInterval(0.5), repeats: false, block: { (_) in
            expectation.fulfill()
        })

        let notice = Notice(message: "Message", action: nil)
        controller.present(notice)

        wait(for: [expectation], timeout: TimeInterval(3))
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

    func testMakeNoticeViewEmptyNotice() throws {
        let action = NoticeAction(title: "") {
            print("")
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

        XCTAssertEqual(controller.pendingNotices, 1)

        controller.dismiss()

        XCTAssertTrue(presenter.dismissed)
        XCTAssertTrue(controller.isPresenting)
        XCTAssertEqual(controller.pendingNotices, 0)
    }
}

extension NoticeContorllerTests {
    static var timeInterval = TimeInterval.zero
    static var timerNoActionCompletionHandler: (Timer) -> Void = { (_) in
        print("Timer Finished")
    }
}

class MockNoticePresenter: NoticePresenter {
    var presented: Bool = false
    var dismissed: Bool = false
    var listeningToKeyboard: Bool = false

    override func presentNoticeView(_ noticeView: NoticeView, completion: @escaping () -> Void) {
        self.noticeView = noticeView
        presented = true

        completion()
    }

    override func dismissNotification(completion: @escaping () -> Void) {
        dismissed = true
        completion()
    }

    override func startListeningToKeyboardNotifications() {
        listeningToKeyboard = true
    }
}

class MockTimerFactory: TimerFactory {
    var timer: Timer?

    override func scheduledTimer(with timeInterval: TimeInterval, completion: @escaping () -> Void) -> Timer {
        if let timer = timer {
            timer.fire()
            return timer
        } else {
            return Timer.scheduledTimer(withTimeInterval: NoticeContorllerTests.timeInterval, repeats: false, block: NoticeContorllerTests.timerNoActionCompletionHandler)
        }
    }
}
