import UIKit

protocol SPCardTransitionObserver: class {
    func cardWasSwipedToDismiss(_ viewController: UIViewController)
}
