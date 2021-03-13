import UIKit

class NoticeController {
    static let shared = NoticeController()

    private var notices: [Notice] = []
    private var current: Notice?
    private let noticePresenter = NoticePresenter()

    private var activeViewIsBeingTouched: Bool = false

    private var isPresenting: Bool {
        current != nil
    }

    private init() { }

    func setupNoticeController() {
        noticePresenter.startListeningToKeyboardNotifications()
    }

    func present(_ notice: Notice) {
        if isPresenting {
            appendToQueueIfNew(notice)
            return
        }

        current = notice
        let noticeView = makeNoticeView(from: notice)

        noticePresenter.presentNoticeView(noticeView) {
            if !self.activeViewIsBeingTouched {
                self.dismiss(noticeView)
            }
        }
    }

    private func dismiss(_ noticeView: NoticeView) {
        noticePresenter.dismissNotification {
            self.current = nil
            if !self.notices.isEmpty {
                self.present(self.notices.removeFirst())
            }
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
}

extension NoticeController: NoticePresentingDelegate {
    func noticePressBegan() {
        if !noticePresenter.isPresenting {
            return
        }
        guard let timer = noticePresenter.timer else {
            return
        }

        timer.invalidate()
    }

    func noticePressEnded() {
        guard let noticeView = noticePresenter.noticeView else {
            return
        }
        dismiss(noticeView)
    }
}
