import UIKit

final class SPCardDismissalAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private var animator: UIViewImplicitlyAnimating?

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return UIKitConstants.animationShortDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let animator = interruptibleAnimator(using: transitionContext)
        animator.startAnimation()
    }

    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        if let animator = animator {
            return animator
        }

        guard let view = transitionContext.view(forKey: .from) else {
            fatalError()
        }

        let animationBlock: () -> Void = {
            view.transform = CGAffineTransform(translationX: 0.0, y: view.frame.size.height)
        }

        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext),
                                              curve: .easeIn,
                                              animations: animationBlock)

        animator.addCompletion { (_) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

        self.animator = animator

        return animator
    }
}
