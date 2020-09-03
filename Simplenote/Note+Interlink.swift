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

        let shortened = title.truncateWords(upTo: SimplenoteConstants.simplenoteInterlinkMaxTitleLength)
        let url = SimplenoteConstants.simplenoteScheme + "://" + SimplenoteConstants.simplenoteInterlinkHost + "/" + key
        return "[" + shortened + "](" + url + ")"
    }
}
