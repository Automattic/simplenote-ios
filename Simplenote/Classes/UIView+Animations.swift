import Foundation
import UIKit


// MARK: - UIView's Animation Methods
//
extension UIView {
    /// Animation for reloading the view
    ///
    enum ReloadAnimation {
        case slideLeading
        case slideTrailing
        case shake
    }

    /// Slide direction
    ///
    enum SlideDirection {
        case leading
        case trailing

        /// Direction considering user interface layout direction
        ///
        var isLeft: Bool {
            let left = self == .leading
            if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
                return !left
            }
            return left
        }
    }

    /// Animates a visibility switch, when applicable.
    /// - Note: We're animating the Alpha property, and effectively switching the `isHidden` property onCompletion.
    ///
    func animateVisibility(isHidden: Bool, duration: TimeInterval = UIKitConstants.animationQuickDuration) {
        guard self.isHidden != isHidden else {
            return
        }

        let animationAlpha = isHidden ? UIKitConstants.alpha0_0 : UIKitConstants.alpha1_0

        UIView.animate(withDuration: duration) {
            self.isHidden = isHidden
            self.alpha = animationAlpha
        }
    }

    /// Performs a FadeIn animation
    ///
    func fadeIn(onCompletion: ((Bool) -> Void)? = nil) {
        alpha = .zero

        UIView.animate(withDuration: UIKitConstants.animationQuickDuration, animations: {
            self.alpha = UIKitConstants.alpha1_0
        }, completion: onCompletion)
    }

    /// Performs a FadeOut animation
    ///
    func fadeOut(onCompletion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: UIKitConstants.animationQuickDuration, animations: {
            self.alpha = UIKitConstants.alpha0_0
        }, completion: onCompletion)
    }

    /// Reload the view with the specified animation
    ///
    func reload(with animation: ReloadAnimation, in containerView: UIView, viewUpdateBlock: @escaping () -> Void) {
        if animation == .shake {
            shake() { _ in
                viewUpdateBlock()
            }
            return
        }

        guard let snapshot = snapshotView(afterScreenUpdates: true) else {
            viewUpdateBlock()
            return
        }

        superview?.insertSubview(snapshot, aboveSubview: self)
        viewUpdateBlock()

        let slideDirection: SlideDirection = animation == .slideLeading ? .leading : .trailing

        snapshot.slideOut(in: containerView, direction: slideDirection) { _ in
            snapshot.removeFromSuperview()
        }
        slideIn(in: containerView, direction: slideDirection)
    }

    /// Slide the view out of the container view
    ///
    func slideOut(in containerView: UIView, direction: SlideDirection, onCompletion: ((Bool) -> Void)? = nil) {
        let frameInContainer = convert(bounds, to: containerView)

        let targetTransform: CGAffineTransform = {
            if direction.isLeft {
                return transform.translatedBy(x: -frameInContainer.maxX, y: 0)
            } else {
                return transform.translatedBy(x: containerView.frame.width - frameInContainer.minX, y: 0)
            }
        }()

        UIView.animate(withDuration: UIKitConstants.animationShortDuration, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.transform = targetTransform
        }, completion: onCompletion)
    }

    /// Slide the view in from the outside of container view
    ///
    func slideIn(in containerView: UIView, direction: SlideDirection, onCompletion: ((Bool) -> Void)? = nil) {
        let frameInContainer = convert(bounds, to: containerView)
        let originalTransform = transform

        transform = {
            if direction.isLeft {
                return transform.translatedBy(x: containerView.frame.width - frameInContainer.minX, y: 0)
            } else {
                return transform.translatedBy(x: -frameInContainer.maxX, y: 0)
            }
        }()

        UIView.animate(withDuration: UIKitConstants.animationShortDuration, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.transform = originalTransform
        }, completion: onCompletion)
    }

    /// Shake the view
    ///
    @objc
    func shake(onCompletion: ((Bool) -> Void)? = nil) {
        let translation: CGFloat = 2.0
        let leftTranslation = transform.translatedBy(x: translation, y: 0.0)
        let rightTranslation = transform.translatedBy(x: -translation, y: 0.0)
        let originalTransform = transform

        transform = leftTranslation
        UIView.animate(withDuration: 0.07, delay: 0.0, options: [.autoreverse, .repeat]) {
            UIView.setAnimationRepeatCount(5)
            self.transform = rightTranslation
        } completion: { (completed) in
            self.transform = originalTransform
            onCompletion?(completed)
        }
    }
}
