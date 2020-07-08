import XCTest
@testable import Simplenote


// MARK: - ResultsObjectsChangesetTests
//
class ResultsObjectsChangesetTests: XCTestCase {

    /// Verifies that `ResultsObjectsChangeset` properly groups `delete` changes.
    ///
    func testDeleteChangesAreProperlyGrouped() {
        let sampleChanges = newSampleObjectsChanges()
        let changeset = ResultsObjectsChangeset(objectChanges: sampleChanges)
        var deleteChanges = [IndexPath]()

        for change in sampleChanges {
            switch change {
            case .delete(let indexPath):
                deleteChanges.append(indexPath)

            case .move(let oldIndexPath, _):
                deleteChanges.append(oldIndexPath)

            default:
                break
            }
        }

        XCTAssertEqual(changeset.deleted.count, deleteChanges.count)
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

        XCTAssertEqual(changeset.updated.count, updates.count)
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
        return changes.compactMap { change in
            switch change {
            case .delete(let indexPath):
                return indexPath

            case .move(let oldIndexPath, _):
                return oldIndexPath

            default:
                return nil
            }
        }
    }

    func extractInsertedPaths(from changes: [ResultsObjectChange]) -> [IndexPath] {
        return changes.compactMap { change in
            switch change {
            case .insert(let indexPath):
                return indexPath

            case .move(_, let newIndexPath):
                return newIndexPath

            default:
                return nil
            }
        }
    }

    func extractUpdatedPaths(from changes: [ResultsObjectChange]) -> [IndexPath] {
        return changes.compactMap { change in
            switch change {
            case .move(_, let newIndexPath):
                return newIndexPath

            case .update(let indexPath):
                return indexPath

            default:
                return nil
            }
        }
    }
}
