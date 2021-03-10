import UIKit

class NoticePresenter: KeyboardObservable {

    // MARK: Properties
    //
    var containerView = PassthruView(frame: .zero)
    var noticeView: NoticeView?
    var noticeBottomConstraint: NSLayoutConstraint?

    var isPresenting: Bool {
        noticeView != nil
    }
    private var keyboardNotificationTokens: [Any]?

    private init() { }

    deinit {
        stopListeningToKeyboardNotifications()
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

        let delay = noticeView.actionTitle == nil ? Times.waitShort : Times.waitLong

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
    func keyboardDidChangeFrame(beginFrame: CGRect?, endFrame: CGRect?, animationDuration: TimeInterval?, animationCurve: UInt?) {
    }
    func keyboardWillChangeFrame(beginFrame: CGRect?, endFrame: CGRect?, animationDuration: TimeInterval?, animationCurve: UInt?) {
    }
    func startListeningToKeyboardNotifications() {
        keyboardNotificationTokens = addKeyboardObservers()
    }

    func stopListeningToKeyboardNotifications() {
        guard let tokens = keyboardNotificationTokens else {
            return
        }

        removeKeyboardObservers(with: tokens)
        keyboardNotificationTokens = nil
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
