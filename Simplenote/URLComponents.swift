import Foundation

extension URLComponents {
    static func simplenoteURLComponents(with host: String? = nil) -> URLComponents? {
        var components = URLComponents(string: .simplenotePath())
        components?.host = host

        return components
    }
}
