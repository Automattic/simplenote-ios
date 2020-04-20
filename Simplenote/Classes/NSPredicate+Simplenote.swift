import Foundation


// MARK: - NSPredicate Methods
//
extension NSPredicate {

    /// Returns a collection of NSPredicates that will match, as a compound, a given Search Text
    ///
    @objc(predicateForSearchText:)
    static func predicateForNotes(searchText: String) -> NSPredicate {
        let keywords = searchText.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .whitespaces)
        var output = [NSPredicate]()

        for keyword in keywords where keyword.isEmpty == false {
            guard let tag = keyword.lowercased().suffix(afterPrefix: lowercasedSearchOperatorForTags) else {
                output.append( NSPredicate(format: "content CONTAINS[cd] %@", keyword) )
                continue
            }

            guard !tag.isEmpty else {
                continue
            }

            output.append( NSPredicate(format: "tags CONTAINS[cd] %@", formattedTag(for: tag)) )
        }

        guard !output.isEmpty else {
            return NSPredicate(value: true)
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
        return NSPredicate(format: "tags CONTAINS[c] %@", formattedTag(for: tag))
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

    /// Returns a NSPredicate that will match Tags with a given Keyword
    ///
    /// -   We'll always analyze the last token in the string
    ///     -   Whenever the last token contains `tag:`, we'll lookup Tags with names containing the payload, excluding exact matches
    ///     -   Otherwise we'll match Tags **containing** the last token
    ///     -   If the `tag:` operator has no actual payload, **every single tag** will be matched (Always True Predicate)
    ///
    @objc
    static func predicateForTag(keyword: String) -> NSPredicate {
        let keywords = keyword.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .whitespaces)
        let last = keywords.last?.lowercased() ?? String()

        guard let tag = last.suffix(afterPrefix: lowercasedSearchOperatorForTags) else {
            return NSPredicate(format: "name CONTAINS[cd] %@", last)
        }

        guard tag.isEmpty == false else {
            return NSPredicate(value: true)
        }

        return NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "name CONTAINS[cd] %@", tag),
            NSPredicate(format: "name <>[c] %@", tag)
        ])
    }
}


// MARK: - Private Methods
//
private extension NSPredicate {

    /// Returns the received tag, escaped and surrounded by quotes: ensures only the *exact* tag matches are hit
    ///
    static func formattedTag(for tag: String) -> String {
        let filtered = tag.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "/", with: "\\/")
        return String(format: "\"%@\"", filtered)
    }

    /// Search Operator for Tags: Case Insensitive
    ///
    static var lowercasedSearchOperatorForTags: String {
        String.searchOperatorForTags.lowercased()
    }
}
