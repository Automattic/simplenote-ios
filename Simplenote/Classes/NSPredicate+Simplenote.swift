import Foundation


// MARK: - NSPredicate Methods
//
extension NSPredicate {

    /// Returns a NSPredicate that will match Notes with the specified `deleted` flag
    ///
    @objc(predicateForNotesWithDeletedStatus:)
    static func predicateForNotesWithStatus(deleted: Bool) -> NSPredicate {
        let status = NSNumber(booleanLiteral: deleted)
        return NSPredicate(format: "deleted == %@", status)
    }

    /// Returns a NSPredicate that will match:
    ///
    ///     A. Empty JSON Arrays (with random padding)
    ///     B. Empty Strings
    ///
    @objc
    static func predicateForUntaggedNotes() -> NSPredicate {
        // Since the `Tags` field is a JSON Encoded Array, we'll need to look up for Untagged Notes with a RegEx:
        // Empty String  (OR)  Spaces* + [ + Spaces* + ] + Spaces*
        let regex = "^()|(null)|(\\s*\\[\\s*]\\s*)$"
        return NSPredicate(format: "tags MATCHES[n] %@", regex)
    }

    /// Returns a NSPredicate that will match a given Tag
    ///
    @objc
    static func predicateForTag(with name: String) -> NSPredicate {
        let filtered = name.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "/", with: "\\/")

        // Individual tags are surrounded by quotes, thus adding quotes to the selected tag ensures only the
        // correct notes are shown
        let format = String(format: "\"%@\"", filtered)
        return NSPredicate(format: "tags CONTAINS[c] %@", format)
    }

    /// Returns a NSPredicate that will match a given Tag
    ///
    @objc
    static func predicateForSystemTag(with name: String) -> NSPredicate {
        return NSPredicate(format: "systemTags CONTAINS[c] %@", name)
    }
}
