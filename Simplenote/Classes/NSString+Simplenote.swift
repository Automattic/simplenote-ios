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

    /// Indicates if the receiver is a valid Tag Name
    /// - Important: `Tag.name` is used as the entity's `simperiumKey`, and the backend imposes a length.
    ///              For that reason we must check on the `encoded` lenght (and not the actual raw string length)
    @objc
    var isValidTagName: Bool {
        byEncodingAsTagHash.count <= SimplenoteConstants.maximumTagLength
    }
}
