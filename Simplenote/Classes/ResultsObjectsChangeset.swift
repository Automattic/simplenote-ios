import Foundation


// MARK: - Changeset: Objects
//
struct ResultsObjectsChangeset {
    let deleted:    [ResultsObjectChange]
    let inserted:   [ResultsObjectChange]
    let moved:      [ResultsObjectChange]
    let updated:    [ResultsObjectChange]
}


// MARK: - Convenience Initializers
//
extension ResultsObjectsChangeset {

    init(objectChanges: [ResultsObjectChange]) {
        var deleted     = [ResultsObjectChange]()
        var inserted    = [ResultsObjectChange]()
        var moved       = [ResultsObjectChange]()
        var updated     = [ResultsObjectChange]()

        for change in objectChanges {
            switch change {
            case .delete:
                deleted.append(change)
            case .insert:
                inserted.append(change)
            case .move:
                moved.append(change)
            case .update:
                updated.append(change)
            }
        }

        self.init(deleted: deleted, inserted: inserted, moved: moved, updated: updated)
    }
}
