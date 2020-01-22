import Foundation


// MARK: - SortMode List Methods
//
extension SortMode {

    /// Returns a collection of SortDescriptors, to be applied over Note Entities, matching the Receiver's Case
    ///
    var descriptorsForNotes: [NSSortDescriptor] {
        let sortKeySelector: Selector
        var sortSelector: Selector?
        var ascending = true

        switch self {
        case .alphabeticallyAscending:
            sortKeySelector = #selector(getter: Note.content)
            sortSelector    = #selector(NSString.caseInsensitiveCompare)
        case .alphabeticallyDescending:
            sortKeySelector = #selector(getter: Note.content)
            sortSelector    = #selector(NSString.caseInsensitiveCompare)
            ascending       = false
        case .createdNewest:
            sortKeySelector = #selector(getter: Note.creationDate)
            ascending       = false
        case .createdOldest:
            sortKeySelector = #selector(getter: Note.creationDate)
        case .modifiedNewest:
            sortKeySelector = #selector(getter: Note.modificationDate)
            ascending       = false
        case .modifiedOldest:
            sortKeySelector = #selector(getter: Note.modificationDate)
        }

        return [
            NSSortDescriptor(keyPath: \Note.pinned, ascending: false),
            NSSortDescriptor(key: NSStringFromSelector(sortKeySelector), ascending: ascending, selector: sortSelector)
        ]
    }

    /// Returns a collection of SortDescriptors, to be applied over Tag Entities, matching the Receiver's Case
    ///
    var descriptorsForTags: [NSSortDescriptor] {
        return [
            NSSortDescriptor(keyPath: \Tag.name, ascending: self != .alphabeticallyDescending)
        ]
    }
}
