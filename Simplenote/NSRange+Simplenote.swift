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
}
