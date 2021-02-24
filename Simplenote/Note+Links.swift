import Foundation


// MARK: - Note + Links
//
extension Note {

    /// Internal note link
    ///
    var plainInternalLink: String? {
        guard let key = simperiumKey else {
            return nil
        }

        return SimplenoteConstants.simplenoteScheme + "://" + SimplenoteConstants.simplenoteInterlinkHost + "/" + key
    }

    /// Returns the receiver's Markdown Internal Reference, when possible
    ///
    var markdownInternalLink: String? {
        guard let title = titlePreview, let plainInternalLink = plainInternalLink else {
            return nil
        }

        let shortened = title.truncateWords(upTo: SimplenoteConstants.simplenoteInterlinkMaxTitleLength)
        return "[" + shortened + "](" + plainInternalLink + ")"
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

    func instancesOfInternalLinkIn(_ content: String) -> Int {
        guard let internalLink = plainInternalLink else {
            return 0
        }
        return content.occurancesOf(internalLink)
    }
}
