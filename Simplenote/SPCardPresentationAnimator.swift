import Foundation

final class SPCardPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return UIKitConstants.animationShortDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let view = transitionContext.view(forKey: .to) else {
            return
        }

        view.superview?.setNeedsLayout()
        view.superview?.layoutIfNeeded()

        view.transform = CGAffineTransform(translationX: 0.0, y: view.frame.size.height)

        let animationBlock: () -> Void = {
            view.transform = .identity
        }

        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext),
                                              curve: .easeOut,
                                              animations: animationBlock)

        animator.addCompletion { (_) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        animator.startAnimation()
    }
}
