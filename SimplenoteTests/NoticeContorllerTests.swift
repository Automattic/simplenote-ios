import XCTest
@testable import Simplenote

class NoticeContorllerTests: XCTestCase {
    private lazy var presenter = MockNoticePresenter()
    private lazy var controller = NoticeController(presenter: presenter)

func testSetupNoticeContoller() {
    controller.setupNoticeController()

    XCTAssertTrue(presenter.listeningToKeyboard == true)
    }

    func testPresentNotice() throws {
        let notice = Notice(message: "Message", action: nil)
        controller.present(notice, withTimer: NoticeContorllerTests.noActionTimer)

        XCTAssertTrue(presenter.presented)

        let presentedNoticeView = try XCTUnwrap(presenter.noticeView)
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
        let timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(0.5), repeats: false) { (_) in
            expectation.fulfill()
        }

        let notice = Notice(message: "Message", action: nil)
        controller.present(notice, withTimer: timer)

        wait(for: [expectation], timeout: TimeInterval(3))

    }

    func testMakeNoticeView() {
        let notice = Notice(message: "Message", action: nil)

        controller.present(notice)
        XCTAssertEqual(notice.message, presenter.noticeView?.message)
        XCTAssertNil(presenter.noticeView?.handler)
    }

    func testMakeNoticeViewWithAction() {
        let action = NoticeAction(title: "Title") {
            print("Action")
        }
        let notice = Notice(message: "Message ", action: action)

        controller.present(notice)
        XCTAssertEqual(notice.message, presenter.noticeView?.message)
        XCTAssertEqual(notice.action?.title, presenter.noticeView?.actionTitle)
        XCTAssertNotNil(presenter.noticeView?.handler)
    }

    func testMakeNoticeViewEmptyNotice() {
        let action = NoticeAction(title: "") {
            print("")
        }
        let notice = Notice(message: "", action: action)

        controller.present(notice)
        XCTAssertEqual(notice.message, presenter.noticeView?.message)
        XCTAssertNotEqual(notice.action?.title, presenter.noticeView?.actionTitle)
        XCTAssertNotNil(presenter.noticeView?.handler)
    }

    func testDismiss() {
        let noticeA = Notice(message: "Message A", action: nil)

        controller.present(noticeA, withTimer: NoticeContorllerTests.noActionTimer)

        controller.dismiss()

        XCTAssertTrue(presenter.dismissed)
        XCTAssertFalse(controller.isPresenting)
    }

    func testDismissContinuesToNextNotice() {
        let noticeA = Notice(message: "Message A", action: nil)
        let noticeB = Notice(message: "Message B", action: nil)
        controller.present(noticeA, withTimer: NoticeContorllerTests.noActionTimer)
        controller.present(noticeB, withTimer: NoticeContorllerTests.noActionTimer)

        XCTAssertEqual(controller.pendingNotices, 1)

        controller.dismiss()

        XCTAssertTrue(presenter.dismissed)
        XCTAssertTrue(controller.isPresenting)
        XCTAssertEqual(controller.pendingNotices, 0)
    }
}

extension NoticeContorllerTests {
    static var noActionTimer = Timer.scheduledTimer(withTimeInterval: .zero, repeats: false) { (success) in
        print("timer finished")
    }
}

class MockNoticePresenter: NoticePresentable {
    var presented: Bool = false
    var dismissed: Bool = false
    var listeningToKeyboard: Bool = false

    var noticeView: NoticeView?

    func presentNoticeView(_ noticeView: NoticeView, completion: @escaping (Bool) -> Void) {
        self.noticeView = noticeView
        presented = true

        completion(true)
    }

    func dismissNotification(completion: @escaping () -> Void) {
        dismissed = true
        completion()
    }

    func startListeningToKeyboardNotifications() {
        listeningToKeyboard = true
    }
}
