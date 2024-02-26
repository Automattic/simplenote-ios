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
            if UIApplication.isRTL {
                return !left
            }
            return left
        }

        /// Opposite direction
        ///
        var opposite: SlideDirection {
            return self == .leading ? .trailing : .leading
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

        guard let superview = superview, let snapshot = snapshotView(afterScreenUpdates: true) else {
            viewUpdateBlock()
            return
        }

        superview.insertSubview(snapshot, aboveSubview: self)
        pinSubviewToAllEdges(snapshot)

        superview.setNeedsLayout()
        superview.layoutIfNeeded()

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
        let targetTransform = slideTransformation(in: containerView, for: direction)

        UIView.animate(withDuration: UIKitConstants.animationShortDuration, animations: {
            self.transform = targetTransform
        }, completion: onCompletion)
    }

    /// Slide the view in from the outside of container view
    ///
    func slideIn(in containerView: UIView, direction: SlideDirection, onCompletion: ((Bool) -> Void)? = nil) {
        let originalTransform = transform

        transform = slideTransformation(in: containerView, for: direction.opposite)

        UIView.animate(withDuration: UIKitConstants.animationShortDuration, animations: {
            self.transform = originalTransform
        }, completion: onCompletion)
    }

    private func slideTransformation(in containerView: UIView, for side: SlideDirection) -> CGAffineTransform {
        let frameInContainer = convert(bounds, to: containerView)

        if side.isLeft {
            return transform.translatedBy(x: -frameInContainer.maxX, y: 0)
        }

        return transform.translatedBy(x: containerView.frame.width - frameInContainer.minX, y: 0)
    }

    /// Shake the view
    ///
    func shake(onCompletion: ((Bool) -> Void)? = nil) {
        let translation: CGFloat = 2.0
        let leftTranslation = transform.translatedBy(x: translation, y: 0.0)
        let rightTranslation = transform.translatedBy(x: -translation, y: 0.0)
        let originalTransform = transform

        transform = leftTranslation
        UIView.animate(withDuration: 0.07, delay: 0.0, options: []) {
            UIView.modifyAnimations(withRepeatCount: 5, autoreverses: true, animations: {
                self.transform = rightTranslation
            })
        } completion: { (completed) in
            self.transform = originalTransform
            onCompletion?(completed)
        }
    }
}
