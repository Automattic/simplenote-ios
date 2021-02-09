import UIKit


/// Allows certain presented view controllers to request themselves to be
/// presented at full size instead of inset within the container.
///
protocol ExtensionPresentationTarget {
    var shouldFillContentContainer: Bool { get }
}


final class ExtensionPresentationController: UIPresentationController {

    // MARK: - Private Properties

    private var presentDirection: Direction
    private var dismissDirection: Direction

    private var keyboardNotificationTokens: [Any]?
    private let dimmingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Appearance.dimmingViewBGColor
        view.alpha = Constants.zeroAlpha
        return view
    }()

    // MARK: Initializers

    init(presentedViewController: UIViewController,
         presenting presentingViewController: UIViewController?,
         presentDirection: Direction,
         dismissDirection: Direction) {

        self.presentDirection = presentDirection
        self.dismissDirection = dismissDirection
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }

    // MARK: Presentation Controller Overrides

    override var frameOfPresentedViewInContainerView: CGRect {
        var frame: CGRect = .zero
        if let containerView = containerView {
            frame.size = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerView.bounds.size)
            frame.origin.x = .zero
            frame.origin.y = (containerView.frame.height - frame.height)
        }
        return frame
    }

    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        if let target = container as? ExtensionPresentationTarget,
            target.shouldFillContentContainer == true {
            return parentSize
        }

        return CGSize(width: (parentSize.width), height: (parentSize.height * Appearance.heightRatio))
    }

    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
        presentedView?.layer.cornerRadius = Appearance.cornerRadius
        presentedView?.clipsToBounds = true
    }

    override func presentationTransitionWillBegin() {
        containerView?.insertSubview(dimmingView, at: 0)
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimmingView]|", options: [], metrics: nil, views: ["dimmingView": dimmingView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[dimmingView]|", options: [], metrics: nil, views: ["dimmingView": dimmingView]))

        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = Constants.fullAlpha
            return
        }

        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = Constants.fullAlpha
        })
    }

    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = Constants.zeroAlpha
            return
        }

        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = Constants.zeroAlpha
        })
    }
}

// MARK: - Constants
//
private extension ExtensionPresentationController {

    struct Constants {
        static let fullAlpha: CGFloat                     = 1.0
        static let zeroAlpha: CGFloat                     = 0.0
        static let defaultAnimationDuration: Double       = 0.25
        static let bottomKeyboardMarginPortrait: CGFloat  = 8.0
        static let bottomKeyboardMarginLandscape: CGFloat = 8.0
    }

    struct Appearance {
        static let dimmingViewBGColor                  = UIColor(white: 0.0, alpha: 0.5)
        static let cornerRadius: CGFloat               = 4.0
        static let heightRatio: CGFloat                = 0.90
    }
}
