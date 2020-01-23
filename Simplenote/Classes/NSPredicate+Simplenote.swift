import Foundation


// MARK: - NSPredicate Methods
//
extension NSPredicate {

    /// `tag:123`: Tag Predicate should ignore this keyword
    /// Tags should support partial matches
    ///

    /// Returns a collection of NSPredicates that will match, as a compound, a given Search Text
    ///
    @objc(predicateForSearchText:)
    static func predicateForNotes(searchText: String) -> NSPredicate {
        let keywords = searchText.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .whitespaces)
        var output = [NSPredicate]()

        for keyword in keywords {
            guard let tag = keyword.lowercased().suffix(afterPrefix: .searchOperatorForTags) else {
                output.append( NSPredicate(format: "content CONTAINS[c] %@", keyword) )
                continue
            }

            guard !tag.isEmpty else {
                continue
            }

            output.append( NSPredicate(format: "tags CONTAINS[c] %@", tag) )
        }

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
    /// We'll completely ignore the `tag:` Search Operator, since we're already matching tag names.
    ///
    @objc
    static func predicateForTag(name: String) -> NSPredicate {
        let trimmed = name
                        .lowercased()
                        .replacingOccurrences(of: String.searchOperatorForTags, with: " ")
                        .trimmingCharacters(in: .whitespacesAndNewlines)

        return NSPredicate(format: "name CONTAINS[c] %@", trimmed)
    }
}
