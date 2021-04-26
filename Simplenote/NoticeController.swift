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

    private var isPresenting: Bool {
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
        if isPresenting {
            dismiss(withDuration: UIKitConstants.animationQuickDuration) {
                self.present(notice)
            }
            return
        }

        current = notice
        let noticeView = makeNoticeView(from: notice)

        noticePresenter.presentNoticeView(noticeView) { () in
            let delay = self.current?.action == nil ? Times.shortDelay : Times.longDelay
            self.timer = self.timerFactory.scheduledTimer(with: delay, completion: {
                self.dismiss {
                }
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
    @objc
    private func dismiss(withDuration duration: TimeInterval = UIKitConstants.animationLongDuration, completion: (() -> Void)? = nil) {
        self.timer = nil

        noticePresenter.dismissNotification(withDuration: duration) {
            self.current = nil
            completion?()
        }
    }
}

// MARK: NoticePresenting Delegate
//
extension NoticeController: NoticeInteractionDelegate {
    func noticePressBegan() {
        if !isPresenting {
            return
        }
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

    func noticeWasTapped(_ noticeView: NoticeView) {
        if !isPresenting {
            noticePresenter.dismiss(noticeView)
        }
    }
}

private struct Times {
    static let shortDelay = TimeInterval(1.5)
    static let longDelay = TimeInterval(2.75)
}
