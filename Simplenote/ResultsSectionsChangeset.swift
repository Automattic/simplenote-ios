import Foundation


// MARK: - Changeset: Sections
//
struct ResultsSectionsChangeset {
    let deleted:    [ResultsSectionChange]
    let inserted:   [ResultsSectionChange]
}


// MARK: - Convenience Initializers
//
extension ResultsSectionsChangeset {

    init(sectionChanges: [ResultsSectionChange]) {
        var deleted     = [ResultsSectionChange]()
        var inserted    = [ResultsSectionChange]()

        for change in sectionChanges {
            switch change {
            case .delete:
                deleted.append(change)
            case .insert:
                inserted.append(change)
            }
        }

        self.init(deleted: deleted, inserted: inserted)
    }
}
