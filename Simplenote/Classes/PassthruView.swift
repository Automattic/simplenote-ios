import Foundation


// MARK: - PassthruView: Doesn't capture tap events performed over itself!
//
class PassthruView: UIView {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let output = super.hitTest(point, with: event)
        return output != self ? output : nil
    }
}
