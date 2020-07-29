import Foundation


// MARK: - NSString Simplenote Helpers
//
extension NSString {

    /// Returns the full range of the receiver
    ///
    @objc
    var fullRange: NSRange {
        NSRange(location: .zero, length: length)
    }

    /// Returns the receiver's substring "up to the first space"
    ///
    @objc
    var substringUpToFirstSpace: String {
        components(separatedBy: .space).first ?? String(self)
    }

    /// Encodes the receiver as a `Tag Hash`
    ///
    @objc
    var byEncodingAsTagHash: String {
        precomposedStringWithCanonicalMapping
            .lowercased()
            .addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? self as String
    }
}
