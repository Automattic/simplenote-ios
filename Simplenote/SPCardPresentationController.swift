import Foundation

final class SPCardPresentationController: UIPresentationController {
    let interactor = UIPercentDrivenInteractiveTransition()
    var isInteractive: Bool {
        return panGestureRecognizer.state == .began || panGestureRecognizer.state == .changed
    }

    private lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        return view
    }()

    private lazy var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()

        guard let containerView = containerView,
            let presentedView = presentedViewController.view else {

            return
        }

        containerView.addGestureRecognizer(panGestureRecognizer)

        containerView.addFillingSubview(dimmingView)
        containerView.addSubview(presentedView)

        presentedView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: presentedView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: presentedView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: presentedView.bottomAnchor)
        ])
        let fittingHeight = presentedView.heightAnchor.constraint(equalToConstant: 0)
        fittingHeight.priority = .fittingSizeLevel
        fittingHeight.isActive = true

        dimmingView.alpha = 0.0
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
        }, completion: nil)
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)

        if !completed {
            removeViews()
            removeGestureRecognizer()
        }
    }

    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()

        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.0
        }, completion: nil)

    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)

        if completed {
            removeViews()
            removeGestureRecognizer()
        }
    }

    private func removeViews() {
        dimmingView.removeFromSuperview()
        presentedViewController.view.removeFromSuperview()
    }

    private func removeGestureRecognizer() {
        containerView?.removeGestureRecognizer(panGestureRecognizer)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let gestureView = gesture.view, gesture.translation(in: gestureView).y >= 0 else {
            return
        }

        let percent = min(gesture.translation(in: gestureView).y / presentedViewController.view.bounds.height, 1.0)

        switch gesture.state {
        case .began:
            presentedViewController.dismiss(animated: true, completion: nil)
        case .changed:
            interactor.update(percent)
        case .cancelled:
            interactor.cancel()
        case .ended:
            let velocity = gesture.velocity(in: gestureView).y
            if velocity >= 0 && (percent > 0.5 || velocity > 1600) {
                interactor.finish()
            } else {
                interactor.cancel()
            }
        default:
            break
        }
    }
}
