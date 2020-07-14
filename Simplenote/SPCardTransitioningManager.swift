import Foundation

final class SPCardTransitioningManager: NSObject, UIViewControllerTransitioningDelegate {
    private weak var presentationController: SPCardPresentationController?

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SPCardPresentationAnimator()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SPCardDismissalAnimator()
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let presentationController = presentationController else {
            return nil
        }

        return presentationController.isInteractive ? presentationController.interactor : nil
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = SPCardPresentationController(presentedViewController: presented, presenting: presenting)
        self.presentationController = presentationController
        return presentationController
    }
}
