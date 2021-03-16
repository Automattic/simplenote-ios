import UIKit

class NoticeController {
    // MARK: Proerties
    //
    static let shared = NoticeController()

    private var notices: [Notice] = []
    private var current: Notice?
    private var noticePresenter: NoticePresenter
    private let timerFactory: TimerFactory

    private var timer: Timer? {
        didSet {
            oldValue?.invalidate()
        }
    }

    var isPresenting: Bool {
        current != nil
    }

    // MARK: Life Cycle
    //
    private init(presenter: NoticePresenter = NoticePresenter(), timerFactory: TimerFactory = TimerFactory()) {
        self.timerFactory = timerFactory
        self.noticePresenter = presenter
    }

    init(presenter: NoticePresenter, timerFactor: TimerFactory) {
        self.noticePresenter = presenter
        self.timerFactory = timerFactor
    }

    func setupNoticeController() {
        noticePresenter.startListeningToKeyboardNotifications()
    }

    // MARK: Presenting
    //
    func present(_ notice: Notice) {
        if isPresenting {
            appendToQueueIfNew(notice)
            return
        }

        current = notice
        let noticeView = makeNoticeView(from: notice)

        noticePresenter.presentNoticeView(noticeView) { () in
            let delay = self.current?.action == nil ? Times.shortDelay : Times.longDelay
            self.timer = self.timerFactory.scheduledTimer(with: delay, completion: {
                self.dismiss()
            })
        }
    }

    /// Confirms if a notice is already contained in notices queue. Appends to queue if new
    ///
    private func appendToQueueIfNew(_ notice: Notice) {
        if notices.contains(notice) {
            return
        }

        if notice == current {
            return
        }

        notices.append(notice)
    }

    var pendingNotices: Int {
        notices.count
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
    func dismiss() {
        noticePresenter.dismissNotification {
            self.current = nil

            if !self.notices.isEmpty {
                self.present(self.notices.removeFirst())
            }
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
}

private struct Times {
    static let shortDelay = TimeInterval(1.5)
    static let longDelay = TimeInterval(2.75)
}
