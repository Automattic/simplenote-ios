import XCTest
@testable import Simplenote


// MARK: - ResultsObjectsChangesetTests
//
class ResultsObjectsChangesetTests: XCTestCase {

    /// Verifies that `ResultsObjectsChangeset` properly groups `delete` changes`
    ///
    func testDeleteChangesAreProperlyGrouped() {
        let changeset = ResultsObjectsChangeset(objectChanges: newSampleObjectsChanges())
        let mixedDeleteChanges = changeset.deleted.contains { $0.isDelete == false }

        XCTAssertFalse(mixedDeleteChanges)
    }

    /// Verifies that `ResultsObjectsChangeset` properly groups `insert` changes`
    ///
    func testInsertChangesAreProperlyGrouped() {
        let changeset = ResultsObjectsChangeset(objectChanges: newSampleObjectsChanges())
        let mixedInsertChanges = changeset.inserted.contains { $0.isInsert == false }

        XCTAssertFalse(mixedInsertChanges)
    }

    /// Verifies that `ResultsObjectsChangeset` properly groups `move` changes`
    ///
    func testUpdateChangesAreProperlyGrouped() {
        let changeset = ResultsObjectsChangeset(objectChanges: newSampleObjectsChanges())
        let mixedMoveChanges = changeset.moved.contains { $0.isMove == false }

        XCTAssertFalse(mixedMoveChanges)
    }

    /// Verifies that `ResultsObjectsChangeset` properly groups `update` changes`
    ///
    func testMoveChangesAreProperlyGrouped() {
        let changeset = ResultsObjectsChangeset(objectChanges: newSampleObjectsChanges())
        let mixedUpdateChanges = changeset.updated.contains { $0.isUpdate == false }

        XCTAssertFalse(mixedUpdateChanges)
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
}


// MARK: - ResultsObjectChange Testing Helpers
//
extension ResultsObjectChange {

    /// Indicates if the receiver is a Delete OP
    ///
    var isDelete: Bool {
        guard case .delete = self else {
            return false
        }

        return true
    }

    /// Indicates if the receiver is an Insert OP
    ///
    var isInsert: Bool {
        guard case .insert = self else {
            return false
        }

        return true
    }

    /// Indicates if the receiver is a Move OP
    ///
    var isMove: Bool {
        guard case .move = self else {
            return false
        }

        return true
    }

    /// Indicates if the receiver is an Update OP
    ///
    var isUpdate: Bool {
        guard case .update = self else {
            return false
        }

        return true
    }
}
