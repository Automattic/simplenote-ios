import Foundation

extension URL {
    static func internalUrl(forTag tag: String?) -> URL {
        guard var components = URLComponents.simplenoteURLComponents(with: SimplenoteConstants.simplenoteInternalTagHost),
              let tag = tag else {
            return URL(string: .simplenotePath(withHost: SimplenoteConstants.simplenoteInternalTagHost))!
        }

        components.queryItems = [
            URLQueryItem(name: Constants.tagQueryBase, value: tag)
        ]

        return components.url!
    }

    static func newNoteURL(withTag tag: String? = nil) -> URL {
        guard var components = URLComponents.simplenoteURLComponents(with: Constants.widgetNewNotePath) else {
            return URL(string: .simplenotePath())!
        }

        if let tag = tag {
            components.queryItems = [
                URLQueryItem(name: Constants.tagQueryBase, value: tag)
            ]
        }

        return components.url!
    }

    static func newNoteWidgetURL() -> URL {
        guard var components = URLComponents.simplenoteURLComponents(with: Constants.newNotePath) else {
            return URL(string: .simplenotePath())!
        }

        return components.url!
    }
}

private struct Constants {
    static let tagQueryBase = "tag"
    static let newNotePath = "new"
    static let widgetNewNotePath = "widgetNew"
}
