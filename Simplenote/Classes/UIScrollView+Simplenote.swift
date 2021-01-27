import UIKit

// MARK: - UIScrollView
//
extension UIScrollView {

    /// Returns an offset that is checked against min and max offset
    ///
    func boundedContentOffset(from offset: CGPoint) -> CGPoint {
        let minXOffset = -adjustedContentInset.left
        let minYOffset = -adjustedContentInset.top

        let maxXOffset = contentSize.width - bounds.width + adjustedContentInset.right
        let maxYOffset = contentSize.height - bounds.height + adjustedContentInset.bottom

        return CGPoint(x: max(minXOffset, min(maxXOffset, offset.x)),
                       y: max(minYOffset, min(maxYOffset, offset.y)))
    }
}
