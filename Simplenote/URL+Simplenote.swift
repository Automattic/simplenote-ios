import Foundation

extension URL {
    static func internalUrl(forTag tag: String?) -> URL {
        guard var components = URLComponents.simplenoteURLComponents(with: SimplenoteConstants.simplenoteInternalTagHost),
              let tag = tag else {
            return URL(string: .simplenotePath(withHost: SimplenoteConstants.simplenoteInternalTagHost))!
        }

        components.query = tagQuery(for: tag)

        return components.url!
    }

    static func newNoteURL(withTag tag: String? = nil) -> URL {
        guard var components = URLComponents.simplenoteURLComponents(with: Constants.newNotePath) else {
            return URL(string: .simplenotePath())!
        }

        if let tag = tag {
            components.query = tagQuery(for: tag)
        }

        return components.url!
    }

    static private func tagQuery(for tag: String) -> String {
        Constants.tagQueryBase + tag
    }
}

private struct Constants {
    static let tagQueryBase = "tag="
    static let newNotePath = "new"
}

extension URLComponents {
    static func simplenoteURLComponents(with host: String? = nil) -> URLComponents? {
        var components = URLComponents(string: .simplenotePath())

        if let host = host {
            components?.host = host
        }

        return components
    }
}
