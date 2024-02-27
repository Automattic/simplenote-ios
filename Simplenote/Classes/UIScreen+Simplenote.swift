import Foundation

// MARK: - UIScreen Simplenote Methods
//
extension UIScreen {

    /// Returns the ratio between 1 point and 1 pixel in the current device.
    ///
    @objc
    var pointToPixelRatio: CGFloat {
        return 1 / scale
    }
}
