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

    /// Encodes the receiver as a `Tag Hash`
    ///
    @objc
    var byEncodingAsTagHash: String {
        precomposedStringWithCanonicalMapping
            .lowercased()
            .addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? self as String
    }

    /// Indicates if the receiver contains a valid email address
    ///
    @objc
    var isValidEmailAddress: Bool {
        let predicate = NSPredicate.predicateForEmailValidation()
        return predicate.evaluate(with: self)
    }
}
