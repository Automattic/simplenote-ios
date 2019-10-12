import Foundation


// MARK: - NSPredicate Methods
//
extension NSPredicate {

    /// Returns a NSPredicate that will match:
    ///
    ///     A. Empty JSON Arrays (with random padding)
    ///     B. Empty Strings
    ///
    @objc
    static func predicateForUntaggedNotes() -> NSPredicate {
        // We'll need to match `Tags` with the following RegEx:
        //  Empty String  (OR)  Spaces* + [ + Spaces* + ] + Spaces*
        // Why: `Tags` contains JSON Encoded arrays.
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
