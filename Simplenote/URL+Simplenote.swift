import Foundation

extension URL {
    static func internalUrl(forTag tag: String?) -> URL {
        guard let tag = tag else {
            return URL(string: SimplenoteConstants.simplenoteScheme + "://" + SimplenoteConstants.simplenoteInternalTagHost + Constants.tagQueryBase)!
        }
        return URL(string: SimplenoteConstants.simplenoteScheme +
                "://" +
                SimplenoteConstants.simplenoteInternalTagHost +
                tagQuery(for: tag))!
    }

    static func tagQuery(for tag: String) -> String {
        Constants.tagQueryBase + tag
    }

    static func newNoteURL(withTag tag: String? = nil) -> URL {
        var newNoteURLString = SimplenoteConstants.simplenoteScheme + "://" + Constants.newNotePath

        if let tag = tag {
            newNoteURLString += tagQuery(for: tag)
        }

        return URL(string: newNoteURLString)!
    }
}

private struct Constants {
    static let tagQueryBase = "?tag="
    static let newNotePath = "new"
}
