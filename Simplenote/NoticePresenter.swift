import UIKit

class NoticePresenter: KeyboardObservable {

    // MARK: Properties
    //
    private var containerView = PassthruView(frame: .zero)
    var noticeView: NoticeView?
    private var noticeVariableConstraint: NSLayoutConstraint?

    var isPresenting: Bool {
        noticeView != nil
    }
    private var keyboardHeight: CGFloat = .zero
    private var keyboardFloats: Bool = false
    private var keyboardNotificationTokens: [Any]?
    var timer: Timer?

    private var keyWindow: UIWindow? {
        return UIApplication.shared.windows.first(where: { $0.isKeyWindow })
    }

    private var windowFrame: CGRect {
        return keyWindow?.frame ?? .zero
    }

    // MARK: Lifecycle
    //
    deinit {
        stopListeningToKeyboardNotifications()
    }

    // MARK: Presenting/Dismissing Methods
    //
    func presentNoticeView(_ noticeView: NoticeView, completion: @escaping () -> Void) {
        guard let keyWindow = keyWindow else {
            return
        }
        self.noticeView = noticeView

        containerView.addSubview(noticeView)
        keyWindow.addFillingSubview(containerView)

        noticeVariableConstraint = noticeView.topAnchor.constraint(equalTo: containerView.bottomAnchor)
        noticeVariableConstraint?.isActive = true
        noticeView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        containerView.layoutIfNeeded()

        displayNotificationView() {
            completion()
        }
    }

    private func displayNotificationView(completion: @escaping () -> Void) {
        prepareConstraintToDisplayNotice()

        UIView.animate(withDuration: UIKitConstants.animationLongDuration) {
            self.containerView.layoutIfNeeded()
        } completion: { (_) in
            completion()
        }
    }

    private func makeBottomConstraintConstant() -> CGFloat {
        let constant = Constants.bottomMarginConstant

        if keyboardFloats || keyboardHeight == .zero {
            return constant
        }

        return constant - keyboardHeight
    }

    private func prepareConstraintToDisplayNotice() {
        noticeVariableConstraint?.isActive = false

        let constant = makeBottomConstraintConstant()
        noticeVariableConstraint = noticeView?.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: constant)
        noticeVariableConstraint?.isActive = true
    }

    func dismissNotification(completion: @escaping () -> Void) {
        guard let noticeView = noticeView else {
            return
        }

        let delay = noticeView.handler == nil ? UIKitConstants.animationDelayExtraLong : UIKitConstants.animationDelayExtraExtraLong

        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: { (timer) in
            self.dismissAnimation(noticeView: noticeView) {
                completion()
            }
        })
    }

    @objc
    private func dismissAnimation(noticeView: NoticeView, completion: @escaping () -> Void) {
        UIView.animate(withDuration: UIKitConstants.animationLongDuration) {
            noticeView.alpha = .zero
        } completion: { (_) in
            self.noticeView?.removeFromSuperview()
            self.containerView.removeFromSuperview()
            self.noticeView = nil
            self.timer = nil
            completion()
        }
    }

    // MARK: Keyboard Obserbers
    //
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
        if !isPresenting {
            return
        }

        let animationOptions = UIView.AnimationOptions(arrayLiteral: .beginFromCurrentState, .init(rawValue: curve))

        noticeVariableConstraint?.constant = makeBottomConstraintConstant()
        UIView.animate(withDuration: animationDuration, delay: .zero, options: animationOptions) {
            self.containerView.layoutIfNeeded()
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
