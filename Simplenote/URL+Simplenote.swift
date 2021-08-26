import Foundation

extension URL {
    static func internalUrl(forTag tag: String?) -> URL {
        URL(string: .simplenotePath(withHost: SimplenoteConstants.simplenoteInternalTagHost + tagQuery(for: tag)))!
    }

    static func newNoteURL(withTag tag: String? = nil) -> URL {
        var urlString: String = .simplenotePath(withHost: Constants.newNotePath)

        if let tag = tag {
            urlString.append(tagQuery(for: tag))
        }

        return URL(string: urlString)!
    }

    static private func tagQuery(for tag: String?) -> String {
        var queryString = Constants.tagQueryBase

        if let tag = tag {
            queryString.append(tag)
        }

        return queryString
    }
}

private struct Constants {
    static let tagQueryBase = "?tag="
    static let newNotePath = "new"
}
