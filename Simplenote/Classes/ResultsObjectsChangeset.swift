import Foundation


// MARK: - Changeset: Objects
//
struct ResultsObjectsChangeset {
    let deleted:    [IndexPath]
    let inserted:   [IndexPath]
    let moved:      [(from: IndexPath, to: IndexPath)]
    let updated:    [IndexPath]

    /// Designed Initializer.
    /// - Note: Ensures that Insertions are ASC and deletions are DESC
    ///
    init(deleted: [IndexPath], inserted: [IndexPath], moved: [(from: IndexPath, to: IndexPath)], updated: [IndexPath]) {
        self.deleted = deleted.sorted(by: >)
        self.inserted = inserted.sorted(by: <)
        self.moved = moved
        self.updated = updated
    }
}


// MARK: - Convenience Initializers
//
extension ResultsObjectsChangeset {

    init(objectChanges: [ResultsObjectChange]) {
        var deleted     = [IndexPath]()
        var inserted    = [IndexPath]()
        var moved       = [(from: IndexPath, to: IndexPath)]()
        var updated     = [IndexPath]()

        for change in objectChanges {
            switch change {
            case .delete(let indexPath):
                deleted.append(indexPath)

            case .insert(let indexPath):
                inserted.append(indexPath)

            case .move(let oldIndexPath, let newIndexPath):
                moved.append((from: oldIndexPath, to: newIndexPath))

                // WWDC 2020 @ Labs Recommendation
                updated.append(newIndexPath)

            case .update(let indexPath):
                updated.append(indexPath)
            }
        }

        self.init(deleted: deleted, inserted: inserted, moved: moved, updated: updated)
    }
}
