import UIKit

// MARK: - SPCardTransitionObserver: observe card transitioning
//
protocol SPCardTransitionObserver: class {
    func cardDidDismiss(_ viewController: UIViewController, reason: SPCardDismissalReason)
}
