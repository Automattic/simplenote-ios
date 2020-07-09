import Foundation


// MARK: - Changeset: Objects
//
struct ResultsObjectsChangeset {
    let deleted:    [IndexPath]
    let inserted:   [IndexPath]
    let moved:      [(from: IndexPath, to: IndexPath)]
    let updated:    [IndexPath]
}


// MARK: - Convenience Initializers
//
extension ResultsObjectsChangeset {

    init(objectChanges: [ResultsObjectChange]) {
        var deleted     = [IndexPath]()
        var inserted    = [IndexPath]()
        var moved       = [(IndexPath, IndexPath)]()
        var updated     = [IndexPath]()

        for change in objectChanges {
            switch change {
            case .delete(let indexPath):
                deleted.append(indexPath)

            case .insert(let indexPath):
                inserted.append(indexPath)

            case .move(let oldIndexPath, let newIndexPath):
                moved.append((oldIndexPath, newIndexPath))

                // WWDC 2020 @ Labs Recommendation
                updated.append(newIndexPath)

            case .update(let indexPath):
                updated.append(indexPath)
            }
        }

        self.init(deleted: deleted, inserted: inserted, moved: moved, updated: updated)
    }
}
