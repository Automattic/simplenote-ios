import Foundation


// MARK: - NSRegularExpression
//
extension NSRegularExpression {

    /// Matches Checklists at the beginning of each line
    ///
    @objc
    static let regexForChecklists: NSRegularExpression = {
        try! NSRegularExpression(pattern: "^\\s*(-[ \t]+\\[[xX\\s]\\])", options: .anchorsMatchLines)
    }()

    /// Matches Checklists patterns that can be ANYWHERE in the string, not necessarily at the beginning of the string.
    ///
    @objc
    static let regexForChecklistsEmbeddedAnywhere: NSRegularExpression = {
        try! NSRegularExpression(pattern: "\\s*(-[ \t]+\\[[xX\\s]\\])", options: .anchorsMatchLines)
    }()
}
