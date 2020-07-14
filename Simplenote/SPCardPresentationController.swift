import UIKit

// MARK: - SPCardPresentationController
//
final class SPCardPresentationController: UIPresentationController {
    private let interactor = UIPercentDrivenInteractiveTransition()

    private lazy var cardView = SPCardView()
    private lazy var panGestureRecognizer = UIPanGestureRecognizer(target: self,
                                                                   action: #selector(handlePan(_:)))
    private lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.simplenoteDimmingColor
        return view
    }()

    var activeInteractor: UIViewControllerInteractiveTransitioning? {
        let panGestureIsActive: Bool = {
            switch panGestureRecognizer.state {
            case .began, .changed:
                return true
            default:
                return false
            }
        }()

        return panGestureIsActive ? interactor : nil
    }

    weak var observer: SPCardTransitionObserver?

    override var presentedView: UIView? {
        return cardView
    }

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()

        setupGestureRecognizers()

        addDimmingView()
        addCardView()

        cardView.addContentView(presentedViewController.view)

        dimmingView.alpha = UIKitConstants.alpha0_0
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = UIKitConstants.alpha1_0
        }, completion: nil)
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)

        if !completed {
            removeViews()
            removeGestureRecognizers()
        }
    }

    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()

        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = UIKitConstants.alpha0_0
        }, completion: nil)
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)

        if completed {
            removeViews()
            removeGestureRecognizers()
        }
    }
}

// MARK: - Views
//
private extension SPCardPresentationController {
    func addDimmingView() {
        containerView?.addFillingSubview(dimmingView)
    }

    func addCardView() {
        guard let containerView = containerView else {
            return
        }

        cardView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(cardView)

        let heightConstraint = cardView.heightAnchor.constraint(equalToConstant: 0)
        heightConstraint.priority = .fittingSizeLevel

        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            cardView.topAnchor.constraint(greaterThanOrEqualTo: containerView.safeAreaLayoutGuide.topAnchor),
            heightConstraint
        ])
    }

    func removeViews() {
        dimmingView.removeFromSuperview()
        cardView.removeFromSuperview()
    }

    func setupGestureRecognizers() {
        containerView?.addGestureRecognizer(panGestureRecognizer)
    }

    func removeGestureRecognizers() {
        containerView?.removeGestureRecognizer(panGestureRecognizer)
    }
}

// MARK: - Swipe to dismiss
//
private extension SPCardPresentationController {
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let gestureView = gesture.view else {
            return
        }

        let verticalTranslation = gesture.translation(in: gestureView).y
        guard verticalTranslation >= 0 else {
            return
        }

        let percentComplete = min(verticalTranslation / cardView.bounds.height, 1.0)

        switch gesture.state {
        case .began:
            beginSwipeToDismiss(percentComplete)
        case .changed:
            updateSwipeToDismiss(percentComplete)
        case .cancelled:
            cancelSwipeToDismiss()
        case .ended:
            let velocity = gesture.velocity(in: gestureView).y
            finishOrCancelSwipeToDismiss(percentComplete, velocity: velocity)
        default:
            break
        }
    }

    func beginSwipeToDismiss(_ percentComplete: CGFloat) {
        presentedViewController.dismiss(animated: true, completion: nil)
        updateSwipeToDismiss(percentComplete)
    }

    func updateSwipeToDismiss(_ percentComplete: CGFloat) {
        if percentComplete >= 1.0 {
            finishSwipeToDismiss()
        } else {
            interactor.update(percentComplete)
        }
    }

    func finishOrCancelSwipeToDismiss(_ percentComplete: CGFloat, velocity: CGFloat) {
        if velocity >= 0 &&
            (percentComplete > Constants.dismissalPercentThreshold || velocity > Constants.dismissalVelocityThreshold) {

            finishSwipeToDismiss()
        } else {
            cancelSwipeToDismiss()
        }
    }

    func finishSwipeToDismiss() {
        interactor.finish()
        observer?.cardWasSwipedToDismiss(presentedViewController)
    }

    func cancelSwipeToDismiss() {
        interactor.cancel()
    }
}

// MARK: - Constants
//
private struct Constants {
    static let dismissalPercentThreshold = CGFloat(0.3)
    static let dismissalVelocityThreshold = CGFloat(1600)
}
