import Foundation
import SimplenoteSearch

extension SearchQuery {
    convenience init(searchText: String) {
        self.init(searchText: searchText, settings: .default)
    }
}

extension SearchQuerySettings {
    static var `default`: SearchQuerySettings {
        let localizedKeyword = NSLocalizedString("tag:", comment: "Search Operator for tags. Please preserve the semicolons when translating!")
        return SearchQuerySettings(tagsKeyword: "tag:", localizedTagKeyword: localizedKeyword)
    }
}
