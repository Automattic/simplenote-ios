import UIKit

// MARK: - SPCardPresentationController: Manages presentation and swipe to dismiss
//
final class SPCardPresentationController: UIPresentationController {
    private let transitionInteractor = UIPercentDrivenInteractiveTransition()

    private lazy var cardView = SPCardView()
    private lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.simplenoteDimmingColor
        return view
    }()

    private lazy var panGestureRecognizer = UIPanGestureRecognizer(target: self,
                                                                   action: #selector(handlePan(_:)))

    /// Returns a transition interactor only if swipe to dismiss is currently in progress
    ///
    var activeTransitionInteractor: UIViewControllerInteractiveTransitioning? {
        let swipeToDismissIsActive: Bool = {
            switch panGestureRecognizer.state {
            case .began, .changed:
                return true
            default:
                return false
            }
        }()

        return swipeToDismissIsActive ? transitionInteractor : nil
    }

    /// Observer for transition related events
    ///
    weak var observer: SPCardTransitionObserver?

    /// Returns our own card wrapper view instead of default view controller view
    ///
    override var presentedView: UIView? {
        return cardView
    }

    // MARK: - Presentation

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()

        setupGestureRecognizers()

        addDimmingView()
        addCardView()

        cardView.addContentView(presentedViewController.view)

        fadeInDimmingView()
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)

        if !completed {
            removeViews()
            removeGestureRecognizers()
        }
    }

    // MARK: - Dismissal

    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        fadeOutDimmingView()
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

    func fadeInDimmingView() {
        dimmingView.alpha = UIKitConstants.alpha0_0
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = UIKitConstants.alpha1_0
        }, completion: nil)
    }

    func fadeOutDimmingView() {
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = UIKitConstants.alpha0_0
        }, completion: nil)
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
        // Handle only movements towards the bottom of the screen
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
            transitionInteractor.update(percentComplete)
        }
    }

    func finishOrCancelSwipeToDismiss(_ percentComplete: CGFloat, velocity: CGFloat) {
        let isMovingDown = velocity >= 0
        if isMovingDown &&
            (percentComplete > Constants.dismissalPercentThreshold || velocity > Constants.dismissalVelocityThreshold) {

            finishSwipeToDismiss()
        } else {
            cancelSwipeToDismiss()
        }
    }

    func finishSwipeToDismiss() {
        transitionInteractor.finish()
        observer?.cardWasSwipedToDismiss(presentedViewController)
    }

    func cancelSwipeToDismiss() {
        transitionInteractor.cancel()
    }
}

// MARK: - Constants
//
private struct Constants {
    static let dismissalPercentThreshold = CGFloat(0.3)
    static let dismissalVelocityThreshold = CGFloat(1600)
}
