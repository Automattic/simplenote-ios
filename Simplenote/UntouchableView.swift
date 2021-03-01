import UIKit

class UntouchableView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let visibleViews = subviews.filter { view -> Bool in
            return view.alpha >= 0.01 && !view.isHidden && view.isUserInteractionEnabled
        }
        for view in visibleViews {
            let relativePoint = convert(point, to: view)
            if view.point(inside: relativePoint, with: event) {
                return true
            }
        }
        return false
    }
}
