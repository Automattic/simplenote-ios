import Foundation

extension URL {
    static func internalUrl(for tag: String) -> URL {
        URL(string: SimplenoteConstants.simplenoteScheme +
                "://" +
                SimplenoteConstants.simplenoteInternalTagHost +
                tagQuery(for: tag))!
    }

    static func tagQuery(for tag: String) -> String {
        Constants.tagQueryBase + tag
    }

    static func newNoteURL(withTag tag: String? = nil) -> URL {
        var newNoteURLString = SimplenoteConstants.simplenoteScheme + "://new"

        if let tag = tag {
            newNoteURLString += tagQuery(for: tag)
        }

        return URL(string: newNoteURLString)!
    }
}

private struct Constants {
    static let tagQueryBase = "?tag="
}
