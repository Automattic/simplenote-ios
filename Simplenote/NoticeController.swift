import UIKit

class NoticeController {
    static let shared = NoticeController()

    private var notices: [Notice] = []
    private var current: Notice?
    private let noticePresenter = NoticePresenter()

    private var activeViewIsBeingTouched: Bool = false

    private init() { }

    func setupNoticeController() {
        noticePresenter.startListeningToKeyboardNotifications()
    }

    func present(_ notice: Notice) {
        if noticePresenter.isPresenting {
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
        DispatchQueue.main.asyncAfter(deadline: .now() + Times.tapDelay) {
            self.noticePresenter.dismissNotification {
                self.current = nil
                if !self.notices.isEmpty {
                    self.present(self.notices.removeFirst())
                }
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
        activeViewIsBeingTouched = true
    }

    func noticePressEnded() {
        activeViewIsBeingTouched = false

        guard let noticeView = noticePresenter.noticeView else {
            return
        }
        dismiss(noticeView)
    }
}

private struct Times {
    static let tapDelay = TimeInterval(2)
}
