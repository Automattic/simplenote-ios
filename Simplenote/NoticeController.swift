import UIKit

class NoticeController {
    // MARK: Proerties
    //
    static let shared = NoticeController()

    private var notices: [Notice] = []
    private var current: Notice?
    private let noticePresenter = NoticePresenter()

    private var activeViewIsBeingTouched: Bool = false
    private var timer: Timer?

    private var isPresenting: Bool {
        current != nil
    }

    // MARK: Life Cycle
    //
    private init() { }

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

        noticePresenter.presentNoticeView(noticeView) { (_) in
            let delay = self.current?.action == nil ? Times.shortDelay : Times.longDelay
            self.timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: { (_) in
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
    private func dismiss() {
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
extension NoticeController: NoticePresentingDelegate {
    func noticePressBegan() {
        if !isPresenting {
            return
        }
        guard let timer = timer else {
            return
        }

        timer.invalidate()
    }

    func noticePressEnded() {
        timer = Timer.scheduledTimer(withTimeInterval: Times.shortDelay, repeats: false, block: { (_) in
            self.dismiss()
        })
    }

    func noticeWasTapped() {
        self.dismiss()
    }
}

private struct Times {
    static let shortDelay = TimeInterval(1.5)
    static let longDelay = TimeInterval(2.75)
}
