import Foundation

// MARK: - SortMode List Methods
//
extension NSSortDescriptor {

    /// Returns a NSSortDescriptor, to be applied over Note collections, so that the resulting collection reflects the specified `SortMode`
    ///
    static func descriptorForNotes(sortMode: SortMode) -> NSSortDescriptor {
        let sortKeySelector: Selector
        var sortSelector: Selector?
        var ascending = true

        switch sortMode {
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

        return NSSortDescriptor(key: NSStringFromSelector(sortKeySelector), ascending: ascending, selector: sortSelector)
    }

    /// Returns a NSSortDescriptor that, when applied over a Tags collection, results in the Pinned Notes to be on top
    ///
    static func descriptorForPinnedNotes() -> NSSortDescriptor {
        return NSSortDescriptor(keyPath: \Note.pinned, ascending: false)
    }

    /// Returns a NSSortDescriptor, to be applied over Tag collections. Yields a sorted collection of Tags, by name, ascending
    ///
    static func descriptorForTags() -> NSSortDescriptor {
        let key = NSStringFromSelector(#selector(getter: Tag.name))
        let selector = #selector(NSString.caseInsensitiveCompare)

        return NSSortDescriptor(key: key, ascending: true, selector: selector)
    }
}
