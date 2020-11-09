import Foundation


// MARK: - Note
//
extension Note {

    /// Indicates if the receiver is a blank document
    ///
    @objc
    var isBlank: Bool {
        objectID.isTemporaryID && content?.count == .zero && tagsArray?.count == .zero
    }

    /// Returns the Creation / Modification date for a given SortMode
    ///
    func date(for sortMode: SortMode) -> Date? {
        switch sortMode {
        case .alphabeticallyAscending, .alphabeticallyDescending:
            return nil

        case .createdNewest, .createdOldest:
            return creationDate

        case .modifiedNewest, .modifiedOldest:
            return modificationDate
        }
    }

    /// Returns the collection user emails with who we're sharing this document
    ///
    var emailTags: [String] {
        guard let tags = tagsArray as? [String] else {
            return []
        }

        return tags.filter {
            $0.isValidEmailAddress
        }
    }
}

// MARK: - Previews
//
extension Note {

    /// Create title and body previews from content
    @objc
    func createPreview() {
        let (titleRange, bodyRange) = NoteContentHelper.structure(of: content)

        self.titlePreview = titlePreview(with: titleRange)
        self.bodyPreview = bodyPreview(with: bodyRange)

        updateTagsArray()
    }

    private func titlePreview(with range: NSRange) -> String {
        guard !range.isNotFound else {
            return NSLocalizedString("New note...", comment: "Empty Note Placeholder")
        }

        let result = content.nsString.substring(with: range)
        return result.droppingPrefix(Constants.titleMarkdownPrefix)
    }

    private func bodyPreview(with range: NSRange) -> String? {
        guard !range.isNotFound else {
            return nil
        }

        let cappedRange = range.capped(at: Constants.bodyPreviewCap)
        let result = content.nsString.substring(with: cappedRange)
        return result.replacingNewlinesWithSpaces()
    }
}

// MARK: - Constants
//
private struct Constants {
    static let titleMarkdownPrefix = "# "
    static let bodyPreviewCap = 500
}
