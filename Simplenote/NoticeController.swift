import UIKit

class NoticeController {

    private enum State {
        case inactive
        case presenting
        case dismissing
    }

    // MARK: Proerties
    //
    static let shared = NoticeController()

    private var notices: [Notice] = []
    private var current: Notice?
    private let noticePresenter: NoticePresenter
    private let timerFactory: TimerFactory
    private var state: State = .inactive

    private var timer: Timer? {
        didSet {
            oldValue?.invalidate()
        }
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
        appendToQueueIfNew(notice)
        dismissNoticeIfNeeded {
            self.presentNextIfPossible()
        }
    }

    /// Confirms if a notice is already contained in notices queue. Appends to queue if new
    ///
    private func appendToQueueIfNew(_ notice: Notice) {
        if notices.contains(notice) {
            return
        }

        notices.append(notice)
    }

    private func dismissNoticeIfNeeded(completion: (() -> Void)?) {
        switch state {
        case .inactive:
            presentNextIfPossible()
        case .presenting:
            dismiss(withDuration: UIKitConstants.animationQuickDuration, completion: completion)
        case .dismissing:
            current = nil
            timer = nil
            noticePresenter.cancel()
            completion?()
        }
    }

    private func presentNextIfPossible() {
        guard !notices.isEmpty else {
            return
        }
        state = .presenting
        let notice = notices.removeFirst()

        current = notice
        let noticeView = makeNoticeView(from: notice)

        noticePresenter.presentNoticeView(noticeView) { () in
            self.timer = self.timerFactory.scheduledTimer(with: self.delayTime(), completion: {
                self.dismiss(withDuration: self.animationDuration())
            })
        }
    }

    private func delayTime() -> TimeInterval {
        let delay = current?.action == nil ? Times.shortDelay : Times.longDelay
        return notices.isEmpty ? delay : .zero
    }

    private func animationDuration() -> TimeInterval {
        return notices.isEmpty ? UIKitConstants.animationLongDuration : UIKitConstants.animationShortDuration
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
    func dismiss(withDuration duration: TimeInterval, completion: (() -> Void)? = nil) {
        state = .dismissing
        timer = nil

        noticePresenter.dismissNotification(withDuration: duration) {
            self.state = .inactive
            self.current = nil

            completion?()
            self.presentNextIfPossible()
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
            self.dismiss(withDuration: self.animationDuration())
        })
    }

    func actionWasTapped() {
        dismiss(withDuration: animationDuration())
    }
}

private struct Times {
    static let shortDelay = TimeInterval(1.5)
    static let longDelay = TimeInterval(2.75)
}
