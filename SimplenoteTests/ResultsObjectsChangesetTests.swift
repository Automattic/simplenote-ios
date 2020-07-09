import XCTest
@testable import Simplenote


// MARK: - ResultsObjectsChangesetTests
//
class ResultsObjectsChangesetTests: XCTestCase {

    /// Verifies that `ResultsObjectsChangeset` properly groups `delete` changes.
    ///
    func testDeleteChangesAreProperlyGrouped() {
        let changes = newSampleObjectsChanges()
        let changeset = ResultsObjectsChangeset(objectChanges: changes)
        let deletions = extractDeletedPaths(from: changes)

        XCTAssertEqual(changeset.deleted.count, deletions.count)
    }

    /// Verifies that `ResultsObjectsChangeset` properly groups `insert` changes.
    ///
    func testInsertChangesAreProperlyGrouped() {
        let changes = newSampleObjectsChanges()
        let changeset = ResultsObjectsChangeset(objectChanges: changes)
        let insertions = extractInsertedPaths(from: changes)

        XCTAssertEqual(changeset.inserted.count, insertions.count)
    }

    /// Verifies that `ResultsObjectsChangeset` properly groups `update` changes.
    ///
    func testUpdateChangesAreProperlyGrouped() {
        let changes = newSampleObjectsChanges()
        let changeset = ResultsObjectsChangeset(objectChanges: changes)
        let updates = extractUpdatedPaths(from: changes)
        let moved = extractMovedPaths(from: changes)

        XCTAssertEqual(changeset.updated.count, updates.count + moved.count)
    }

    /// Verifies that `ResultsObjectsChangeset` sorts `delete` changes in a DESC order
    ///
    func testDeleteChangesAreSortedDescending() {
        let changes = newSampleObjectsChanges()
        let changeset = ResultsObjectsChangeset(objectChanges: changes)
        let deleted = changeset.deleted

        for (index, current) in deleted.enumerated() where index < deleted.count - 1 {
            let next = deleted[index + 1]
            XCTAssert(current >= next)
        }
    }

    /// Verifies that `ResultsObjectsChangeset` sorts `inserted` changes in an ASC order
    ///
    func testInsertChangesAreSortedDescending() {
        let changes = newSampleObjectsChanges()
        let changeset = ResultsObjectsChangeset(objectChanges: changes)
        let inserted = changeset.inserted

        for (index, current) in inserted.enumerated() where index < inserted.count - 1 {
            let next = inserted[index + 1]
            XCTAssert(current <= next)
        }
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
