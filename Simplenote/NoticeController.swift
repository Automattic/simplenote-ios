import UIKit

class NoticeController {
    // MARK: Proerties
    //
    static let shared = NoticeController()

    private var current: Notice?
    private let noticePresenter: NoticePresenter
    private let timerFactory: TimerFactory

    private var timer: Timer? {
        didSet {
            oldValue?.invalidate()
        }
    }

    private var presenting: Bool {
        current != nil
    }

    // MARK: Life Cycle
    //
    init(presenter: NoticePresenter = NoticePresenter(), timerFactory: TimerFactory = TimerFactory()) {
        self.timerFactory = timerFactory
        self.noticePresenter = presenter
    }

    func setupNoticeController() {
        noticePresenter.startListeningToKeyboardNotifications()
    }

    // MARK: Presenting
    //
    func present(_ notice: Notice) {
        if presenting {
            dismiss(withDuration: .zero) {
                self.present(notice)
            }
            return
        }

        current = notice
        let noticeView = makeNoticeView(from: notice)

        noticePresenter.presentNoticeView(noticeView) {
            let delay = self.current?.action == nil ? Times.shortDelay : Times.longDelay
            self.timer = self.timerFactory.scheduledTimer(with: delay, completion: {
                self.dismiss()
            })
        }
    }

    private func makeNoticeView(from notice: Notice) -> NoticeView {
        let noticeView: NoticeView = NoticeView.instantiateFromNib()
        noticeView.message = notice.message
        noticeView.actionTitle = notice.action?.title
        noticeView.handler = notice.action?.handler
        noticeView.delegate = self

        return noticeView
    }

    // MARK: Dismissing
    //
    private func dismiss(withDuration duration: TimeInterval = UIKitConstants.animationLongDuration, completion: (() -> Void)? = nil) {
        timer = nil
        current = nil

        noticePresenter.dismissNotification(withDuration: duration) {
            completion?()
        }
    }
}

// MARK: NoticePresenting Delegate
//
extension NoticeController: NoticeInteractionDelegate {
    func noticePressBegan() {
        timer = nil
    }

    func noticePressEnded() {
        timer = timerFactory.scheduledTimer(with: Times.shortDelay, completion: {
            self.dismiss()
        })
    }

    func actionWasTapped() {
        dismiss()
    }
}

private struct Times {
    static let shortDelay = TimeInterval(1.5)
    static let longDelay = TimeInterval(2.75)
}
