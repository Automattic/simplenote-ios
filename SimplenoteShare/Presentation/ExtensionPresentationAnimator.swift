import UIKit

/// Direction to transition from/to.
///
/// - left: Enter/leave screen via the left edge.
/// - top: Enter/leave screen via the top edge.
/// - right: Enter/leave screen via the left edge.
/// - bottom: Enter/leave screen via the bottom edge.
///
enum Direction {
    case left
    case top
    case right
    case bottom
}

/// Animator that animates the presented View Controller from/to a specific `Direction`.
///
final class ExtensionPresentationAnimator: NSObject {
    let direction: Direction
    let isPresentation: Bool

    init(direction: Direction, isPresentation: Bool) {
        self.direction = direction
        self.isPresentation = isPresentation
        super.init()
    }
}

// MARK: - UIViewControllerAnimatedTransitioning Conformance
//
extension ExtensionPresentationAnimator: UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Constants.animationDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let key = isPresentation ? UITransitionContextViewControllerKey.to : UITransitionContextViewControllerKey.from
        let controller = transitionContext.viewController(forKey: key)!

        if isPresentation {
            transitionContext.containerView.addSubview(controller.view)
        }

        let presentedFrame = transitionContext.finalFrame(for: controller)
        var dismissedFrame = presentedFrame
        switch direction {
        case .left:
            dismissedFrame.origin.x = -presentedFrame.width
        case .right:
            dismissedFrame.origin.x = transitionContext.containerView.frame.size.width
        case .top:
            dismissedFrame.origin.y = -presentedFrame.height
        case .bottom:
            dismissedFrame.origin.y = transitionContext.containerView.frame.size.height
        }

        let initialFrame = isPresentation ? dismissedFrame : presentedFrame
        let finalFrame = isPresentation ? presentedFrame : dismissedFrame

        let animationDuration = transitionDuration(using: transitionContext)
        controller.view.frame = initialFrame
        UIView.animate(withDuration: animationDuration, animations: {
            controller.view.frame = finalFrame
        }) { finished in
            transitionContext.completeTransition(finished)
        }
    }
}

// MARK: - Constants
//
private struct Constants {
    static let animationDuration: Double = 0.33
}
