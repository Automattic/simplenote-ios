import UIKit

// MARK: - SPCardTransitionObserver: observe card transitioning
//
protocol SPCardTransitionObserver: class {
    func cardWasSwipedToDismiss(_ viewController: UIViewController)
}
