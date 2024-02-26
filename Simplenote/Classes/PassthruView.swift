import Foundation

// MARK: - PassthruView: Doesn't capture tap events performed over itself!
//
class PassthruView: UIView {

    /// Callback is invoked when interacted with this view and not with subviews
    ///
    var onInteraction: (() -> Void)?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let output = super.hitTest(point, with: event)
        if output == self {
            onInteraction?()
            return nil
        }

        return output
    }
}
