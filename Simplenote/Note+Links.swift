import Foundation


// MARK: - Note + Links
//
extension Note {

    /// Returns the receiver's Markdown Internal Reference, when possible
    ///
    var internalLink: String? {
        guard let title = titlePreview, let key = simperiumKey else {
            return nil
        }

        let shortened = title.truncateWords(upTo: SimplenoteConstants.simplenoteInterlinkMaxTitleLength)
        let url = SimplenoteConstants.simplenoteScheme + "://" + SimplenoteConstants.simplenoteInterlinkHost + "/" + key
        return "[" + shortened + "](" + url + ")"
    }

    /// Returns the full Public Link to the current document
    ///
    @objc
    var publicLink: String? {
        guard let targetURL = publishURL, targetURL.isEmpty == false, published else {
            return nil
        }

        return SimplenoteConstants.simplenotePublishedBaseURL + targetURL
    }
}
