import UIKit

class NoticePresenter {

    // MARK: Properties
    //
    private var noticeView: UIView?
    private var containerView: PassthruView?
    private var noticeVariableConstraint: NSLayoutConstraint?

    private var keyboardHeight: CGFloat = .zero
    private var keyboardFloats: Bool = false
    private var keyboardNotificationTokens: [Any]?

    private var keyWindow: UIWindow? {
        return UIApplication.shared.windows.first(where: { $0.isKeyWindow })
    }
    private var windowFrame: CGRect {
        return keyWindow?.frame ?? .zero
    }

    private var bottomConstraintConstant: CGFloat {
        let constant = Constants.bottomMarginConstant

        if keyboardFloats || keyboardHeight == .zero {
            return constant
        }

        return constant - keyboardHeight
    }

    // MARK: Lifecycle
    //
    deinit {
        stopListeningToKeyboardNotifications()
    }

    // MARK: Presenting Methods
    //
    func presentNoticeView(_ noticeView: NoticeView, completion: @escaping (Bool) -> Void) {
        guard let containerView = prepareContainerView() else {
            return
        }

        add(view: noticeView, into: containerView)

        displayNotificationView(containerView: containerView,
                                noticeView: noticeView,
                                completion: completion)
    }

    private func prepareContainerView() -> PassthruView? {
        guard let keyWindow = keyWindow else {
            return nil
        }

        let containerView = PassthruView(frame: .zero)
        self.containerView = containerView

        keyWindow.addFillingSubview(containerView)

        return containerView
    }

    private func add(view: UIView, into containerView: PassthruView) {
        containerView.addSubview(view)

        noticeVariableConstraint = view.topAnchor.constraint(equalTo: containerView.bottomAnchor)
        noticeVariableConstraint?.isActive = true
        view.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        containerView.layoutIfNeeded()

    }

    private func displayNotificationView(containerView: PassthruView, noticeView: NoticeView, completion: @escaping (Bool) -> Void) {
        prepareConstraintToDisplayNotice(containerView: containerView, noticeView: noticeView)

        UIView.animate(withDuration: UIKitConstants.animationLongDuration, animations: {
            containerView.layoutIfNeeded()
        }, completion: completion)
    }

    private func prepareConstraintToDisplayNotice(containerView: PassthruView, noticeView: NoticeView) {
        noticeVariableConstraint?.isActive = false

        let constant = bottomConstraintConstant
        noticeVariableConstraint = noticeView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: constant)
        noticeVariableConstraint?.isActive = true
    }

    // MARK: Dismissing Methods
    //
    func dismissNotification(completion: @escaping () -> Void) {
        guard let containerView = containerView,
              let noticeView = noticeView else {
            return
        }
        UIView.animate(withDuration: UIKitConstants.animationLongDuration) {
            noticeView.alpha = .zero
        } completion: { (_) in
            noticeView.removeFromSuperview()
            containerView.removeFromSuperview()
            self.noticeView = nil
            self.containerView = nil
            completion()
        }
    }
}

// MARK: Keyboard Observable
//
extension NoticePresenter: KeyboardObservable {
    func keyboardDidChangeFrame(beginFrame: CGRect?, endFrame: CGRect?, animationDuration: TimeInterval?, animationCurve: UInt?) {
        guard let endFrame = endFrame,
              let animationCurve = animationCurve,
              let animationDuration = animationDuration else {
            return
        }
        updateKeyboardHeight(with: endFrame)
        animateNoticeToNewKeyboardLocation(frame: endFrame, curve: animationCurve, animationDuration: animationDuration)
    }

    func keyboardWillChangeFrame(beginFrame: CGRect?, endFrame: CGRect?, animationDuration: TimeInterval?, animationCurve: UInt?) {
        guard let endFrame = endFrame,
              let animationCurve = animationCurve,
              let animationDuration = animationDuration else {
            return
        }
        updateKeyboardHeight(with: endFrame)
        animateNoticeToNewKeyboardLocation(frame: endFrame, curve: animationCurve, animationDuration: animationDuration)
    }

    private func updateKeyboardHeight(with frame: CGRect) {
        keyboardHeight = frame.intersection(windowFrame).height
        keyboardFloats = frame.maxY < windowFrame.height
    }

    private func animateNoticeToNewKeyboardLocation(frame: CGRect, curve: UInt, animationDuration: TimeInterval) {
        guard let containerView = containerView else {
            return
        }

        let animationOptions = UIView.AnimationOptions(arrayLiteral: .beginFromCurrentState, .init(rawValue: curve))

        noticeVariableConstraint?.constant = bottomConstraintConstant
        UIView.animate(withDuration: animationDuration, delay: .zero, options: animationOptions) {
            containerView.layoutIfNeeded()
        }
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

private struct Constants {
    static let bottomMarginConstant = CGFloat(-50)
}
