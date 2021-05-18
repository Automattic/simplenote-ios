import UIKit

// MARK: - SPCardDismissalReason: reason why card view controller was dismissed
//
enum SPCardDismissalReason {
    /// Swipe down
    ///
    case swipe

    /// Tap outside of the card
    ///
    case outsideTap
}


// MARK: - SPCardPresentationControllerDelegate
//
protocol SPCardPresentationControllerDelegate: AnyObject {
    func cardDidDismiss(_ viewController: UIViewController, reason: SPCardDismissalReason)
}


// MARK: - SPCardPresentationController: Manages presentation and swipe to dismiss
//
final class SPCardPresentationController: UIPresentationController {
    private lazy var cardView = SPCardView()
    private lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.simplenoteDimmingColor
        return view
    }()

    private lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                   action: #selector(handleTap(_:)))

    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let gestureRecognizer = UIPanGestureRecognizer(target: self,
                                                       action: #selector(handlePan(_:)))
        gestureRecognizer.delegate = self
        return gestureRecognizer
    }()

    private var compactWidthLayoutConstraints: [NSLayoutConstraint] = []
    private var regularWidthLayoutConstraints: [NSLayoutConstraint] = []
    private var regularHeightLayoutConstraints: [NSLayoutConstraint] = []

    /// Transition interactor is set only during swipe to dismiss
    ///
    private(set) var transitionInteractor: UIPercentDrivenInteractiveTransition?

    /// Delegate for presentation (and dismissal) related events
    ///
    weak var presentationDelegate: SPCardPresentationControllerDelegate?

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

// MARK: - Handle changes in trait collection
//
extension SPCardPresentationController {
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.updateConstraints(for: newCollection)
        }, completion: nil)
    }

    private func updateConstraints(for collection: UITraitCollection) {
        NSLayoutConstraint.deactivate(compactWidthLayoutConstraints + regularWidthLayoutConstraints + regularHeightLayoutConstraints)

        let newWidthConstraints = collection.horizontalSizeClass == .regular ? regularWidthLayoutConstraints : compactWidthLayoutConstraints
        NSLayoutConstraint.activate(newWidthConstraints)

        if collection.verticalSizeClass == .regular {
            NSLayoutConstraint.activate(regularHeightLayoutConstraints)
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

        compactWidthLayoutConstraints = [
            cardView.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor),
        ]

        regularWidthLayoutConstraints = [
            cardView.leadingAnchor.constraint(equalTo: containerView.readableContentGuide.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: containerView.readableContentGuide.trailingAnchor),
        ]

        regularHeightLayoutConstraints = [
            cardView.topAnchor.constraint(greaterThanOrEqualTo: containerView.centerYAnchor),
        ]

        let heightConstraint = cardView.heightAnchor.constraint(equalToConstant: 0)
        heightConstraint.priority = .fittingSizeLevel

        NSLayoutConstraint.activate([
            cardView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            cardView.topAnchor.constraint(greaterThanOrEqualTo: containerView.safeAreaLayoutGuide.topAnchor, constant: Constants.cardMinTopMargin),
            heightConstraint
        ])

        updateConstraints(for: presentedViewController.traitCollection)
    }

    func removeViews() {
        dimmingView.removeFromSuperview()
        cardView.removeFromSuperview()
    }

    func setupGestureRecognizers() {
        dimmingView.addGestureRecognizer(tapGestureRecognizer)
        containerView?.addGestureRecognizer(panGestureRecognizer)
    }

    func removeGestureRecognizers() {
        dimmingView.removeGestureRecognizer(tapGestureRecognizer)
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

// MARK: - Gesture Recognizer Delegate
//
extension SPCardPresentationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == panGestureRecognizer,
              let viewController = presentedViewController as? SPCardConfigurable else {
            return true
        }

        let location = gestureRecognizer.location(in: cardView)
        return viewController.shouldBeginSwipeToDismiss(from: location)
    }
}

// MARK: - Swipe to dismiss
//
private extension SPCardPresentationController {
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let gestureView = gestureRecognizer.view else {
            return
        }

        let verticalTranslation = gestureRecognizer.translation(in: gestureView).y
        let cardViewHeight = cardView.bounds.height

        let percentComplete = max(min(verticalTranslation / cardViewHeight, 1.0), 0.0)

        switch gestureRecognizer.state {
        case .began:
            beginSwipeToDismiss(percentComplete)
        case .changed:
            updateSwipeToDismiss(percentComplete)
        case .ended:
            let velocity = gestureRecognizer.velocity(in: gestureView).y
            finishOrCancelSwipeToDismiss(percentComplete, velocity: velocity)
        default:
            cancelSwipeToDismiss()
        }
    }

    func beginSwipeToDismiss(_ percentComplete: CGFloat) {
        transitionInteractor = UIPercentDrivenInteractiveTransition()
        presentedViewController.dismiss(animated: true, completion: nil)
        updateSwipeToDismiss(percentComplete)
    }

    func updateSwipeToDismiss(_ percentComplete: CGFloat) {
        if percentComplete >= 1.0 {
            finishSwipeToDismiss()
        } else {
            transitionInteractor?.update(percentComplete)
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
        transitionInteractor?.finish()
        cleanupTransitionInteractor()

        presentationDelegate?.cardDidDismiss(presentedViewController, reason: .swipe)
    }

    func cancelSwipeToDismiss() {
        transitionInteractor?.cancel()
        cleanupTransitionInteractor()
    }

    func cleanupTransitionInteractor() {
        transitionInteractor = nil
    }
}

// MARK: - Tap to dismiss
//
private extension SPCardPresentationController {
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let locationInCardView = gestureRecognizer.location(in: cardView)
        // Ignore taps inside card view
        if cardView.bounds.contains(locationInCardView) {
            return
        }

        presentedViewController.dismiss(animated: true, completion: nil)
        presentationDelegate?.cardDidDismiss(presentedViewController, reason: .outsideTap)
    }
}

// MARK: - Constants
//
private struct Constants {
    static let dismissalPercentThreshold = CGFloat(0.3)
    static let dismissalVelocityThreshold = CGFloat(1600)
    static let cardMinTopMargin = CGFloat(10.0)
}
