import Foundation


// MARK: - Note + Interlink
//
extension Note {

    /// Returns the receiver's Markdown Internal Reference, when possible
    ///
    var markdownInternalLink: String? {
        guard let title = titlePreview, let key = simperiumKey else {
            return nil
        }

        let shortened = title
            .prefix(SimplenoteConstants.interlinkMaximumLength)
            .trimmingCharacters(in: .whitespaces)

        return "[" + shortened + "](" + SimplenoteConstants.interlinkBaseURL + key + ")"
    }
}
