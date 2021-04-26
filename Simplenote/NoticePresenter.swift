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

    func startListeningToKeyboardNotifications() {
        keyboardNotificationTokens = addKeyboardObservers()
    }

    func setupNavigationControllerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(navigationControllerDidUpdate), name: .SPNavigationControllerWillDismiss, object: nil)
    }

    func stopListeningToKeyboardNotifications() {
        guard let tokens = keyboardNotificationTokens else {
            return
        }

        removeKeyboardObservers(with: tokens)
        keyboardNotificationTokens = nil
    }

    @objc
    private func navigationControllerDidUpdate() {
        print("From notice presenter notification")
        updateBottomConstraint(viewIsDimssing: true)
    }

    // MARK: Presenting Methods
    //
    func presentNoticeView(_ noticeView: NoticeView, completion: @escaping () -> Void) {
        guard let containerView = prepareContainerView() else {
            return
        }
//
//        let nav = SPAppDelegate.shared().navigationController
//
//        if !nav.isToolbarHidden {
//            print("toolbar not hidden")
//
//            if let first = nav.visibleViewController as? SPNoteListViewController {
//                print("note list")
//            }
//        }


        self.noticeView = noticeView
        add(view: noticeView, into: containerView)

        display(view: noticeView, in: containerView) {
            completion()
        }
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

    private func display(view: UIView, in containerView: UIView, completion: @escaping () -> Void) {
        prepareConstraintFor(view: view, in: containerView)

        UIView.animate(withDuration: UIKitConstants.animationShortDuration, animations: {
            containerView.layoutIfNeeded()
        }, completion: { _ in
            completion()
        })
    }

    private func prepareConstraintFor(view: UIView, in containerView: UIView) {
        noticeVariableConstraint?.isActive = false

        let constant = bottomConstraintConstant - constraintWithVisibleToolbar()
        noticeVariableConstraint = view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: constant)
        noticeVariableConstraint?.isActive = true
    }

    private func updateBottomConstraint(viewIsDimssing: Bool = false) {
        guard let noticeView = noticeView,
              let containerView = containerView else {
            return
        }
//        prepareConstraintFor(view: noticeView, in: containerView)
        noticeVariableConstraint?.isActive = false
        if viewIsDimssing == true {
            let constant = bottomConstraintConstant - constraintWithVisibleToolbar()
            noticeVariableConstraint = noticeView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: constant)
            noticeVariableConstraint?.isActive = true
        }

        UIView.animate(withDuration: UIKitConstants.animationQuickDuration) {
            containerView.layoutIfNeeded()
        }
    }

    private func constraintWithVisibleToolbar() -> CGFloat {
        let navigationController = SPAppDelegate.shared().navigationController
        if navigationController.isToolbarHidden {
            return .zero
        }

        if (navigationController.visibleViewController as? OptionsViewController) != nil {
            return .zero
        }

        return navigationController.toolbar.frame.height
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
}

private struct Constants {
    static let bottomMarginConstant = CGFloat(-50)
}
