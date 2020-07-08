import Foundation


// MARK: - Changeset: Objects
//
struct ResultsObjectsChangeset {
    let deleted:    [IndexPath]
    let inserted:   [IndexPath]
    let updated:    [IndexPath]
}


// MARK: - Convenience Initializers
//
extension ResultsObjectsChangeset {

    init(objectChanges: [ResultsObjectChange]) {
        var deleted     = [IndexPath]()
        var inserted    = [IndexPath]()
        var updated     = [IndexPath]()

        for change in objectChanges {
            switch change {
            case .delete(let indexPath):
                deleted.append(indexPath)

            case .insert(let indexPath):
                inserted.append(indexPath)

            case .move(let oldIndexPath, let newIndexPath):
                deleted.append(oldIndexPath)
                inserted.append(newIndexPath)

                // WWDC 2020 @ Labs Recommendation
                updated.append(newIndexPath)

            case .update(let indexPath):
                updated.append(indexPath)
            }
        }

        // Sorting:
        //  - Insertions: Ascending
        //  - Deletions: Descending
        //
        deleted.sort(by: >)
        inserted.sort(by: <)

        self.init(deleted: deleted, inserted: inserted, updated: updated)
    }
}
