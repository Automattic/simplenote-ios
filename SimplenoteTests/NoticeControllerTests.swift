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

    func testControlDismissesNoticeWhenNewNoticePresented() {
        let noticeA = Notice(message: "Message A", action: nil)
        let noticeB = Notice(message: "Message B", action: nil)
        var expectedActions: [MockNoticePresenter.Action] = [
            .present(noticeA.message)
        ]

        controller.present(noticeA)
        controller.present(noticeB)

        expectedActions.append(.dismiss(noticeA.message))
        expectedActions.append(.present(noticeB.message))

        XCTAssertEqual(expectedActions, presenter.actionLog)
        XCTAssertEqual(presenter.lastNoticeView?.message, noticeB.message)
    }

    func testMakeNoticeView() throws {
        let notice = Notice(message: "Message", action: nil)

        controller.present(notice)

        XCTAssertEqual(notice.message, presenter.lastNoticeView?.message)
        XCTAssertEqual(notice.action?.title, presenter.lastNoticeView?.actionTitle)
        XCTAssertNil(presenter.lastNoticeView?.handler)
    }

    func testMakeNoticeViewWithAction() {
        let action = NoticeAction(title: "Title") {
            print("Action")
        }
        let notice = Notice(message: "Message ", action: action)

        checkNoticeViewPropertiesCreatedCorrectly(notice)
    }

    func testMakeNoticeViewWithEmptyNotice() {
        let action = NoticeAction(title: "") { }
        let notice = Notice(message: "", action: action)

        checkNoticeViewPropertiesCreatedCorrectly(notice)
    }

    private func checkNoticeViewPropertiesCreatedCorrectly(_ notice: Notice) {
        controller.present(notice)

        XCTAssertEqual(notice.message, presenter.lastNoticeView?.message)
        XCTAssertEqual(notice.action?.title, presenter.lastNoticeView?.actionTitle)
        XCTAssertNotNil(presenter.lastNoticeView?.handler)
    }

    func testDismiss() throws {
        let noticeA = Notice(message: "Message A", action: nil)

        controller.present(noticeA)
        var expectedActions: [MockNoticePresenter.Action] = [
            .present(noticeA.message)
        ]

        try XCTUnwrap(timerFactory.timer).fire()
        expectedActions.append(.dismiss(noticeA.message))

        XCTAssertEqual(expectedActions, presenter.actionLog)
    }

    func testPressingOnActionDismissesNotice() {
        let action = NoticeAction(title: "Action", handler: {})
        let noticeA = Notice(message: "Message A", action: action)

        controller.present(noticeA)
        var expectedActions: [MockNoticePresenter.Action] = [
            .present(noticeA.message)
        ]

        controller.actionWasTapped()
        expectedActions.append(.dismiss(noticeA.message))

        XCTAssertEqual(expectedActions, presenter.actionLog)
    }

    func testLongPressInvalidatesTimerAndNoticeDoesNotDismiss() {
        let noticeA = Notice(message: "Message A", action: nil)

        controller.present(noticeA)
        let expectedActions: [MockNoticePresenter.Action] = [
            .present(noticeA.message)
        ]

        controller.noticePressBegan()

        XCTAssertEqual(expectedActions, presenter.actionLog)
        XCTAssertNil(timerFactory.timer?.completion)
    }

    func testLongPressReleasedDismissesTimer() throws {
        let noticeA = Notice(message: "Message A", action: nil)

        controller.present(noticeA)
        controller.noticePressBegan()
        controller.noticePressEnded()

        try XCTUnwrap(timerFactory.timer).fire()

        let expectedActions: [MockNoticePresenter.Action] = [
            .present(noticeA.message),
            .dismiss(noticeA.message)
        ]

        XCTAssertEqual(expectedActions, presenter.actionLog)
    }

    func testDismissibleNoticeWillDismissOnPresent() {
        let noticeA = Notice(message: "Message A", action: nil)
        let noticeB = Notice(message: "Message B", action: nil)

        controller.present(noticeA)

        var expectedActions: [MockNoticePresenter.Action] = [
            .present(noticeA.message)
        ]
        XCTAssertEqual(presenter.actionLog, expectedActions)

        controller.present(noticeB)

        expectedActions.append(.dismiss(noticeA.message))
        expectedActions.append(.present(noticeB.message))

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

    override func dismissNotification(withDuration duration: TimeInterval?, completion: @escaping () -> Void) {
        let noticeView = try! XCTUnwrap(lastNoticeView)
        lastNoticeView = nil
        actionLog.append(.dismiss(noticeView.message))
        completion()
    }

    override func startListeningToKeyboardNotifications() {
        listeningToKeyboard = true
    }
}
