import Foundation


// MARK: - NSRegularExpression (Checklists)
//
extension NSRegularExpression {

    /// Matches Checklists at the beginning of each line
    ///
    @objc
    static let regexForChecklists: NSRegularExpression = {
        try! NSRegularExpression(pattern: "^\\s*(-[ \t]+\\[[xX\\s]?\\])", options: .anchorsMatchLines)
    }()

    /// Matches Checklists patterns that can be ANYWHERE in the string, not necessarily at the beginning of the string.
    ///
    @objc
    static let regexForChecklistsEmbeddedAnywhere: NSRegularExpression = {
        try! NSRegularExpression(pattern: "\\s*(-[ \t]+\\[[xX\\s]?\\])", options: .anchorsMatchLines)
    }()


    /// Both our Checklist regexes look like this: `"^\\s*(EXPRESSION)"`
    /// This will produce two resulting NSRange(s): a top level one, including the full match, and a "capture group"
    /// By requesting the Range for `EXPRESSION` we'd be able to track **exactly** the location of our list marker `- [ ]` (disregarding, thus, the leading space).
    ///
    @objc
    static let regexForChecklistsExpectedNumberOfRanges = 2

    /// Checklist's Match Marker Range
    ///
    @objc
    static let regexForChecklistsMarkerRangeIndex = 1
}

// MARK: - NSRegularExpression (Search excerpts)
//
extension NSRegularExpression {

    /// Matches one of the keywords and a short text surrounding it
    ///
    /// - Parameters:
    ///     - keywords: a non-empty list of keywords
    ///
    static func regexForExcerpt(withKeywords keywords: [String]) -> NSRegularExpression {
        guard !keywords.isEmpty else {
            return try! NSRegularExpression(pattern: "^.*{\(Constants.excerptLeadingLength + Constants.excerptTrailingLength)}", options: [])
        }

        let escapedKeywords = keywords.map(NSRegularExpression.escapedPattern).joined(separator: "|")
        /// Patter explanation:
        /// Leading: word boundary + word character + up to `excerptLeadingLength` word characters
        /// Main: word boundary + optional word characters + one of the keywords + optional word characters + word boundary
        /// Trailing: up to `excerptTrailingLength` word characters + word character + word boundary
        let pattern = "(?:\\b\\w[\\w\\W]{0,\(Constants.excerptLeadingLength)})?\\b(?:\\w*(?:\(escapedKeywords))\\w*)\\b(?:[\\w\\W]{0,\(Constants.excerptTrailingLength)}\\w\\b)?"

        return try! NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .useUnicodeWordBoundaries])
    }
}

private struct Constants {
    static let excerptLeadingLength = 30
    static let excerptTrailingLength = 300
}
