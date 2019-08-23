import Foundation


// MARK: - NSIndexPath Helpers
//
extension NSIndexPath {

    /// Maps the receiver into an Integer Value: Section * 10^5 + row.
    ///
    @objc
    var integerValue: Int {
        return section * 100000 + row
    }
}
