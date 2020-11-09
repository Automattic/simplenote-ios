import Foundation

// MARK: - NSRange
//
extension NSRange {
    /// Constant for "not found" range
    ///
    static let notFound = NSRange(location: NSNotFound, length: 0)

    /// Is range location not found?
    ///
    var isNotFound: Bool {
        return location == NSNotFound
    }

    /// Return a new range capped at maxLength
    ///
    func capped(at maxLength: Int) -> NSRange {
        return NSRange(location: location, length: min(length, maxLength))
    }
}
