import Foundation


// MARK: - NSPredicate Methods
//
extension NSPredicate {

    /// Returns a collection of NSPredicates that will match, as a compound, a given Search Text
    ///
    @objc(predicateForSearchText:)
    static func predicateForNotes(searchText: String) -> NSPredicate {
        let words = searchText.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .whitespaces)
        let output = words.map { NSPredicate(format: "content CONTAINS[c] %@", $0) }

        return NSCompoundPredicate(andPredicateWithSubpredicates: output)
    }

    /// Returns a NSPredicate that will match Notes with the specified `deleted` flag
    ///
    @objc(predicateForNotesWithDeletedStatus:)
    static func predicateForNotes(deleted: Bool) -> NSPredicate {
        let status = NSNumber(booleanLiteral: deleted)
        return NSPredicate(format: "deleted == %@", status)
    }

    /// Returns a NSPredicate that will match a given Tag
    ///
    @objc
    static func predicateForNotes(systemTag: String) -> NSPredicate {
        return NSPredicate(format: "systemTags CONTAINS[c] %@", systemTag)
    }

    /// Returns a NSPredicate that will match a given Tag
    ///
    @objc
    static func predicateForNotes(tag: String) -> NSPredicate {
        let filtered = tag.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "/", with: "\\/")

        // Individual tags are surrounded by quotes, thus adding quotes to the selected tag ensures only the
        // correct notes are shown
        let format = String(format: "\"%@\"", filtered)
        return NSPredicate(format: "tags CONTAINS[c] %@", format)
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

    /// Returns a NSPredicate that will match Tags with a given name
    ///
    @objc
    static func predicateForTag(name: String) -> NSPredicate {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return NSPredicate(format: "name CONTAINS[c] %@", trimmed)
    }
}
