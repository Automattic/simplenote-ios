import Foundation
import SimplenoteSearch

@objc
final class SearchQuery: NSObject {
    @objc
    let query: String

    @objc
    var isEmpty: Bool {
        return tags.isEmpty && keywords.isEmpty
    }

    @objc
    private(set) var tags: [String] = []

    @objc
    private(set) var keywords: [String] = []

    init(query: String) {
        self.query = query
        super.init()
        parseQuery()
    }

    private func parseQuery() {
        let queryComponents = query.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .whitespaces)

        for keyword in queryComponents where keyword.isEmpty == false {
            guard let tag = keyword.lowercased().suffix(afterPrefix: String.searchOperatorForTags.lowercased()) else {
                keywords.append(keyword)
                continue
            }

            guard !tag.isEmpty else {
                continue
            }

            tags.append(tag)
        }
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? SearchQuery else {
            return false
        }

        return tags == object.tags && keywords == object.keywords
    }
}
