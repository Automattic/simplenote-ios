import Foundation

// MARK: - NSMutableAttributedString Simplenote Methods
//
extension NSAttributedString {

    /// Returns the full range of the receiver.
    ///
    @objc
    var fullRange: NSRange {
        NSRange(location: .zero, length: length)
    }
}
