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
