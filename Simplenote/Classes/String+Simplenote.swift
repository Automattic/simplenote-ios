import Foundation


// MARK: - String
//
extension String {

    /// Returns the Search Operator we should recognize, when filtering out entities with a given Tag
    ///
    static let searchOperatorForTags = "tag:"


    /// Returns the Suffix string after a given `prefix` (if any!)
    ///
    func suffix(afterPrefix prefix: String) -> String? {
        guard hasPrefix(prefix), count > prefix.count else {
            return nil
        }

        return String(dropFirst(prefix.count))
    }
}
