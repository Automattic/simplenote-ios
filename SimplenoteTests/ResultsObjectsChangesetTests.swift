import XCTest
@testable import Simplenote


// MARK: - ResultsObjectsChangesetTests
//
class ResultsObjectsChangesetTests: XCTestCase {

    /// Verifies that `ResultsObjectsChangeset` properly groups `ResultsObjectsChange` entities into the right collections.
    ///
    func testObjectsChangesetsAreProperlyGroupedIntoTheRightCollections() {
        let changes = newSampleObjectsChanges()
        let changeset = ResultsObjectsChangeset(objectChanges: changes)

        let deleted = extractDeletedPaths(from: changes)
        let inserted = extractInsertedPaths(from: changes)
        let moved = extractMovedPaths(from: changes)
        let updated = extractUpdatedPaths(from: changes)

        XCTAssertEqual(changeset.deleted.count, deleted.count)
        XCTAssertEqual(changeset.inserted.count, inserted.count)
        XCTAssertEqual(changeset.moved.count, moved.count)
        XCTAssertEqual(changeset.updated.count, updated.count + moved.count)
    }
}


// MARK: - Private Helpers
//
private extension ResultsObjectsChangesetTests {

    func newSampleObjectsChanges() -> [ResultsObjectChange] {
        var changes = [ResultsObjectChange]()

        for section in 1...100 {
            for row in 1...100 where (row % 2 == 1) {
                let path0 = IndexPath(row: section, section: row)
                let path1 = IndexPath(row: section, section: row + 1)

                changes.append( .insert(indexPath: path0) )
                changes.append( .delete(indexPath: path0) )
                changes.append( .insert(indexPath: path0) )
                changes.append( .insert(indexPath: path1) )
                changes.append( .move(oldIndexPath: path0, newIndexPath: path1) )
                changes.append( .update(indexPath: path0) )
                changes.append( .update(indexPath: path1) )
            }
        }

        return changes
    }

    func extractDeletedPaths(from changes: [ResultsObjectChange]) -> [IndexPath] {
        return changes.compactMap { change -> IndexPath? in
            guard case let .delete(indexPath) = change else {
                return nil
            }

            return indexPath
        }
    }

    func extractInsertedPaths(from changes: [ResultsObjectChange]) -> [IndexPath] {
        return changes.compactMap { change -> IndexPath? in
            guard case let .insert(indexPath) = change else {
                return nil
            }

            return indexPath
        }
    }

    func extractUpdatedPaths(from changes: [ResultsObjectChange]) -> [IndexPath] {
        return changes.compactMap { change -> IndexPath? in
            guard case let .update(indexPath) = change else {
                return nil
            }

            return indexPath
        }
    }

    func extractMovedPaths(from changes: [ResultsObjectChange]) -> [(from: IndexPath, to: IndexPath)] {
        return changes.compactMap { change -> (IndexPath, IndexPath)? in
            guard case let .move(from, to) = change else {
                return nil
            }

            return (from, to)
        }
    }
}
