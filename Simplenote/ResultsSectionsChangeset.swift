import Foundation


// MARK: - Changeset: Sections
//
struct ResultsSectionsChangeset {
    let deleted:    IndexSet
    let inserted:   IndexSet
}


// MARK: - Convenience Initializers
//
extension ResultsSectionsChangeset {

    init(sectionChanges: [ResultsSectionChange]) {
        var deleted  = IndexSet()
        var inserted = IndexSet()

        for change in sectionChanges {
            switch change {
            case .delete(let sectionIndex):
                deleted.insert(sectionIndex)
            case .insert(let sectionIndex):
                inserted.insert(sectionIndex)
            }
        }

        self.init(deleted: deleted, inserted: inserted)
    }
}
