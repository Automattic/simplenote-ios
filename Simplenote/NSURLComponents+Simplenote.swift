import Foundation

extension NSURLComponents {
    @objc
    func contentFromQuery() -> String? {
        return queryItems?.first(where: { query in
            query.name == "content"
        })?.value
    }

    @objc
    func tagsFromQuery() -> [String]? {
        queryItems?
            .filter({ $0.name == "tag" })
            .compactMap({ $0.value })
            .flatMap({ $0.components(separatedBy: .whitespacesAndNewlines) })
            .filter({ !$0.isEmpty })
    }
}
