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
        let tags = queryItems?.first(where: { query in
            query.name == "tag"
        })

        return tags?.value?.components(separatedBy: .whitespacesAndNewlines)
    }
}
