import UIKit

// MARK: - UISlider + Simplenote
//
extension UISlider {

    /// Rect for thumb
    ///
    var thumbRect: CGRect {
        return thumbRect(forBounds: bounds,
                         trackRect: trackRect(forBounds: bounds),
                         value: value)
    }
}
