import UIKit


// MARK: - PopoverPresenter
//
final class PopoverPresenter {

    private var popoverController: PopoverViewController?

    private let containerViewController: UIViewController
    private let siblingView: UIView?
    private let viewportProvider: () -> CGRect

    private var desiredHeight: CGFloat?

    /// Is presented?
    ///
    var isPresented: Bool {
        return popoverController != nil
    }

    /// Init
    ///
    init(containerViewController: UIViewController,
         viewportProvider: @escaping () -> CGRect,
         siblingView: UIView? = nil) {

        self.containerViewController = containerViewController
        self.viewportProvider = viewportProvider
        self.siblingView = siblingView
    }

    /// Show view controller as a popover around anchor
    ///
    func show(_ viewController: UIViewController, around anchorInWindow: CGRect, desiredHeight: CGFloat? = nil) {
        dismiss()

        self.desiredHeight = desiredHeight

        popoverController = PopoverViewController(viewController: viewController)
        popoverController?.attachWithAnimation(to: containerViewController, below: siblingView)

        relocate(around: anchorInWindow)
    }

    /// Relocates the receiver so that it shows up **around** the specified Anchor Frame
    /// - Important: Frame must be expressed in Window Coordinates. Capisce?
    ///
    func relocate(around anchorInWindow: CGRect) {
        guard let popoverController = popoverController, let view = popoverController.view else {
            return
        }

        let anchor                          = view.convert(anchorInWindow, from: nil)
        let viewport                        = view.convert(viewportProvider(), from: nil)

        let (orientation, viewportSlice)    = calculateViewportSlice(around: anchor, in: viewport)
        let height                          = calculateHeight(viewport: viewportSlice)
        let leftLocation                    = calculateLeftLocation(around: anchor, in: viewport)

        popoverController.containerMaxHeightConstraint.constant = height
        popoverController.containerLeftConstraint.constant = leftLocation

        popoverController.containerTopToTopConstraint.isActive = false
        popoverController.containerTopToBottomConstraint.isActive = false

        switch orientation {
        case .above:
            popoverController.containerTopToBottomConstraint.constant = anchor.minY - Metrics.defaultContentInsets.top
            popoverController.containerTopToBottomConstraint.isActive = true
        case .below:
            popoverController.containerTopToTopConstraint.constant = anchor.maxY + Metrics.defaultContentInsets.top
            popoverController.containerTopToTopConstraint.isActive = true
        }
    }

    /// Adjusts the View by the specified offset
    ///
    func relocate(by deltaY: CGFloat) {
        popoverController?.containerTopToTopConstraint.constant += deltaY
        popoverController?.containerTopToBottomConstraint.constant += deltaY
    }

    func dismiss() {
        popoverController?.detachWithAnimation()
        popoverController = nil
    }
}


// MARK: - Geometry
//
private extension PopoverPresenter {

    /// Returns the Target Origin.X
    ///
    /// -   Parameters:
    ///     - anchor: Frame around which we should position the TableView
    ///     - viewport: Editor's visible frame
    ///
    /// -   Note: We'll align the Table **Text**, horizontally, with regards of the anchor frame. That's why we consider layout margins!
    /// -   Important: Whenever we overflow horizontally, we'll simply ensure there's enough breathing room on the right hand side
    ///
    func calculateLeftLocation(around anchor: CGRect, in viewport: CGRect) -> CGFloat {

        let maximumX = anchor.minX + Metrics.defaultContentWidth + containerViewController.view.layoutMargins.right
        if viewport.width > maximumX {
            return anchor.minX - containerViewController.view.layoutMargins.left
        }

        return anchor.minX + viewport.width - maximumX
    }

    /// We'll always prefer displaying the Autocomplete UI **above** the cursor, whenever such location does not produce clipping.
    /// Even if there's more room at the bottom (that's why a simple max calculation isn't enough!)
    ///
    /// - Important: In order to avoid flipping Up / Down, we'll consider the Maximum Heigh tour TableView can acquire
    ///
    func calculateViewportSlice(around anchor: CGRect, in viewport: CGRect) -> (Orientation, CGRect) {

        let (viewportBelow, viewportAbove)  = viewport.split(by: anchor)

        guard let desiredHeight = desiredHeight else {
            if viewportAbove.height > viewportBelow.height {
                return (.above, viewportAbove)
            }
            return (.below, viewportBelow)
        }

        let deltaAbove = viewportAbove.height - desiredHeight
        let deltaBelow = viewportBelow.height - desiredHeight

        if (deltaAbove >= .zero) || (deltaAbove < .zero && deltaBelow < .zero && deltaAbove > deltaBelow) {
            return (.above, viewportAbove)
        }

        return (.below, viewportBelow)
    }

    /// Returns the target Size.Height for the specified viewport metrics
    ///
    func calculateHeight(viewport: CGRect) -> CGFloat {
        let availableHeight = viewport.height - Metrics.defaultContentInsets.top - Metrics.defaultContentInsets.bottom

        return max(availableHeight, Metrics.minimumHeight)
    }
}


// MARK: - Defines the vertical orientation in which we'll display Popover
//
private enum Orientation {
    case above
    case below
}


// MARK: - Metrics
//
private enum Metrics {
    static let defaultContentInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
    static let defaultContentWidth = CGFloat(300)

    static let minimumHeight = CGFloat(30)
}
