import UIKit

class NoticeController {
    static let shared = NoticeController()

    private var notices: [Notice] = []
    private let noticePresenter = NoticePresenter()

    private var activeViewIsBeingTouched: Bool = false

    private init() { }

    func present(_ notice: Notice) {
        if noticePresenter.isPresenting {
            notices.append(notice)
            return
        }

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
                if !self.notices.isEmpty {
                    self.present(self.notices.removeFirst())
                }
            }
        }
    }

    private func makeNoticeView(from notice: Notice) -> NoticeView {
        let noticeView: NoticeView = NoticeView.instantiateFromNib()
        noticeView.message = notice.message
        noticeView.action = notice.action
        noticeView.delegate = self

        return noticeView
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
