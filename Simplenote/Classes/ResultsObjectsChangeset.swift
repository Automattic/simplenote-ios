import Foundation


// MARK: - Changeset: Objects
//
struct ResultsObjectsChangeset {
    private(set) var deleted    : [IndexPath]
    private(set) var inserted   : [IndexPath]
    private(set) var moved      : [(from: IndexPath, to: IndexPath)]
    private(set) var updated    : [IndexPath]

    init(deleted:   [IndexPath] = [],
         inserted:  [IndexPath] = [],
         moved:     [(from: IndexPath, to: IndexPath)] = [],
         updated:   [IndexPath] = []) {

        self.deleted = deleted
        self.inserted = inserted
        self.moved = moved
        self.updated = updated
    }
}


// MARK: - Public API(s)
//
extension ResultsObjectsChangeset {

    mutating func deletedIndexPath(_ indexPath: IndexPath) {
        deleted.append(indexPath)
    }

    mutating func insertedIndexPath(_ indexPath: IndexPath) {
        inserted.append(indexPath)
    }

    mutating func movedIndexPath(from oldIndexPath: IndexPath, to newIndexPath: IndexPath) {
        moved.append((oldIndexPath, newIndexPath))

        // WWDC 2020 @ Labs Recommendation
        updated.append(newIndexPath)
    }

    mutating func updatedIndexPath(_ indexPath: IndexPath) {
        updated.append(indexPath)
    }
}


// MARK: - Transposing
//
extension ResultsObjectsChangeset {

    /// Why? Because displaying data coming from multiple ResultsController onScreen... just requires us to adjust sectionIndexes
    ///
    func transposed(toSection section: Int) -> ResultsObjectsChangeset {
        let newDeleted = deleted.map { path in
            path.transpose(toSection: section)
        }

        let newInserted = inserted.map { path in
            path.transpose(toSection: section)
        }

        let newMoved = moved.map { (oldPath, newPath) in
            (oldPath.transpose(toSection: section), newPath.transpose(toSection: section))
        }

        let newUpdated = updated.map { path in
            path.transpose(toSection: section)
        }

        return ResultsObjectsChangeset(deleted: newDeleted, inserted: newInserted, moved: newMoved, updated: newUpdated)
    }
}
