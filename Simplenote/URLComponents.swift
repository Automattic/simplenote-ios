import Foundation

extension URLComponents {
    static func simplenoteURLComponents(with host: String? = nil) -> URLComponents? {
        var components = URLComponents(string: .simplenotePath())

        if let host = host {
            components?.host = host
        }

        return components
    }
}
