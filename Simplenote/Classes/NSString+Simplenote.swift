import Foundation


// MARK: - NSString Simplenote Helpers
//
extension NSString {

    /// Returns the full range of the receiver
    ///
    @objc
    var rangeOfEntireString: NSRange {
        NSRange(location: 0, length: length)
    }
}
