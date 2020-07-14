import UIKit

final class SPCardTransitioningManager: NSObject, UIViewControllerTransitioningDelegate {
    private weak var presentationController: SPCardPresentationController?
    weak var observer: SPCardTransitionObserver?

    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        let presentationController = SPCardPresentationController(presentedViewController: presented,
                                                                  presenting: presenting)
        presentationController.observer = observer
        self.presentationController = presentationController
        return presentationController
    }

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SPCardPresentationAnimator()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SPCardDismissalAnimator()
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return presentationController?.activeInteractor
    }
}
