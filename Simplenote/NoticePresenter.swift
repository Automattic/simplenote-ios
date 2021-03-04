import UIKit

class NoticePresenter {

    // MARK: Properties
    //
    var containerView = UntouchableView(frame: .zero)
    var noticeView: NoticeView?
    var noticeBottomConstraint: NSLayoutConstraint?

    var isPresenting: Bool {
        noticeView != nil
    }

    // MARK: Presenting/Dismissing Methods
    //
    func presentNoticeView(_ noticeView: NoticeView, completion: @escaping () -> Void) {
        guard let keyWindow = getKeyWindow() else {
            return
        }
        self.noticeView = noticeView

        containerView.addSubview(noticeView)
        keyWindow.addFillingSubview(containerView)

        noticeBottomConstraint = noticeView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: Constants.notificationStartingPosition)
        noticeBottomConstraint?.isActive = true
        noticeView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true

        containerView.layoutIfNeeded()
        displayNotificationView() {
            completion()
        }
    }

    private func displayNotificationView(completion: @escaping () -> Void) {
        guard let noticeView = noticeView else {
            return
        }

        noticeBottomConstraint?.constant = Constants.notificationOnScreenPosition

        let delay = noticeView.action == nil ? Times.waitShort : Times.waitLong

        UIView.animate(withDuration: Times.animationTime) {
            self.containerView.layoutIfNeeded()
        } completion: { (_) in
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                completion()
            }
        }
    }

    func dismissNotification(completion: @escaping () -> Void) {
        guard let noticeView = noticeView else {
            return
        }

        UIView.animate(withDuration: Times.animationTime) {
            noticeView.alpha = 0
        } completion: { (_) in
            self.noticeView?.removeFromSuperview()
            self.containerView.removeFromSuperview()
            self.noticeView = nil
            completion()
        }
    }
}


extension NoticePresenter {
    // Convenience method to fetch current key window
    //
    func getKeyWindow() -> UIWindow? {
        return UIApplication.shared.windows.first(where: { $0.isKeyWindow })
    }
}

private struct Times {
    static let waitShort = 1.5
    static let waitLong = 2.75
    static let animationTime = TimeInterval(0.5)
    static let tapWait = TimeInterval(3)
}

private struct Constants {
    static let notificationBottomMargin = CGFloat(-150)
    static let notificationStartingPosition = CGFloat(100)
    static let notificationOnScreenPosition = CGFloat(-50)
}
