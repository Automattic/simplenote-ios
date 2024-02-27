import UIKit

/// Allows certain presented view controllers to request themselves to be
/// presented at full size instead of inset within the container.
///
protocol ExtensionPresentationTarget {
    var shouldFillContentContainer: Bool { get }
}

final class ExtensionPresentationController: UIPresentationController {

    // MARK: - Private Properties

    private var presentDirection: Direction
    private var dismissDirection: Direction

    private var keyboardNotificationTokens: [Any]?
    private let dimmingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Appearance.dimmingViewBGColor
        view.alpha = Constants.zeroAlpha
        return view
    }()

    // MARK: Initializers

    init(presentedViewController: UIViewController,
         presenting presentingViewController: UIViewController?,
         presentDirection: Direction,
         dismissDirection: Direction) {

        self.presentDirection = presentDirection
        self.dismissDirection = dismissDirection
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.keyboardNotificationTokens = self.addKeyboardObservers()
    }

    deinit {
        guard let tokens = keyboardNotificationTokens else {
            return
        }

        removeKeyboardObservers(with: tokens)
    }

    // MARK: Presentation Controller Overrides

    override var frameOfPresentedViewInContainerView: CGRect {
        var frame: CGRect = .zero
        if let containerView = containerView {
            frame.size = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerView.bounds.size)
            frame.origin.x = (containerView.frame.width - frame.width) / 2.0
            frame.origin.y = (containerView.frame.height - frame.height) / 2.0
        }
        return frame
    }

    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        if let target = container as? ExtensionPresentationTarget,
            target.shouldFillContentContainer == true {
            return parentSize
        }

        let widthRatio = traitCollection.verticalSizeClass != .compact ? Appearance.widthRatio : Appearance.widthRatioCompactVertical
        let heightRatio = traitCollection.verticalSizeClass != .compact ? Appearance.heightRatio : Appearance.heightRatioCompactVertical
        return CGSize(width: (parentSize.width * widthRatio), height: (parentSize.height * heightRatio))
    }

    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
        presentedView?.layer.cornerRadius = Appearance.cornerRadius
        presentedView?.clipsToBounds = true
    }

    override func presentationTransitionWillBegin() {
        containerView?.insertSubview(dimmingView, at: 0)
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimmingView]|", options: [], metrics: nil, views: ["dimmingView": dimmingView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[dimmingView]|", options: [], metrics: nil, views: ["dimmingView": dimmingView]))

        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = Constants.fullAlpha
            return
        }

        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = Constants.fullAlpha
        })
    }

    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = Constants.zeroAlpha
            return
        }

        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = Constants.zeroAlpha
        })
    }
}

// MARK: - KeyboardObservable Conformance
//
extension ExtensionPresentationController: KeyboardObservable {

    func keyboardWillChangeFrame(beginFrame: CGRect?, endFrame: CGRect?, animationDuration: TimeInterval?, animationCurve: UInt?) {
        let keyboardFrame = endFrame ?? .zero
        let duration = animationDuration ?? Constants.defaultAnimationDuration
        animate(with: presentedView!.convert(keyboardFrame, from: nil), duration: duration, animationCurve: animationCurve)
    }

    func keyboardDidChangeFrame(beginFrame: CGRect?, endFrame: CGRect?, animationDuration: TimeInterval?, animationCurve: UInt?) {
        // TODO:
        // We should really animate (again) here, but not doing so. The layout mechanism is broken when called twice.
    }

    private func animate(with keyboardFrame: CGRect, duration: TimeInterval, animationCurve: UInt?) {
        let presentedFrame = frameOfPresentedViewInContainerView
        let translatedFrame = getTranslationFrame(keyboardFrame: keyboardFrame, presentedFrame: presentedFrame)
        var animationOptions: UIView.AnimationOptions = []
        if let animationCurve = animationCurve {
            animationOptions = UIView.AnimationOptions(rawValue: animationCurve)
        }

        UIView.animate(withDuration: duration, delay: 0.0, options: animationOptions, animations: {
            self.presentedView?.frame = translatedFrame
        })
    }

    private func getTranslationFrame(keyboardFrame: CGRect, presentedFrame: CGRect) -> CGRect {
        let keyboardTopPadding = traitCollection.verticalSizeClass != .compact ? Constants.bottomKeyboardMarginPortrait : Constants.bottomKeyboardMarginLandscape
        let keyboardTop = UIScreen.main.bounds.height - (keyboardFrame.size.height + keyboardTopPadding)
        let presentedViewBottom = presentedFrame.origin.y + presentedFrame.height
        let offset = presentedViewBottom - keyboardTop

        guard offset > 0.0  else {
            return presentedFrame
        }

        let newHeight = presentedFrame.size.height - offset
        let frame = CGRect(x: presentedFrame.origin.x, y: presentedFrame.origin.y, width: presentedFrame.size.width, height: newHeight)
        return frame
    }
}

// MARK: - Constants
//
private extension ExtensionPresentationController {

    struct Constants {
        static let fullAlpha: CGFloat                     = 1.0
        static let zeroAlpha: CGFloat                     = 0.0
        static let defaultAnimationDuration: Double       = 0.25
        static let bottomKeyboardMarginPortrait: CGFloat  = 8.0
        static let bottomKeyboardMarginLandscape: CGFloat = 8.0
    }

    struct Appearance {
        static let dimmingViewBGColor                  = UIColor(white: 0.0, alpha: 0.5)
        static let cornerRadius: CGFloat               = 4.0
        static let widthRatio: CGFloat                 = 0.90
        static let widthRatioCompactVertical: CGFloat  = 0.90
        static let heightRatio: CGFloat                = 0.80
        static let heightRatioCompactVertical: CGFloat = 0.80
    }
}
