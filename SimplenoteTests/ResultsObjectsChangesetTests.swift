import XCTest
@testable import Simplenote


// MARK: - ResultsObjectsChangesetTests
//
class ResultsObjectsChangesetTests: XCTestCase {

    /// Verifies that `ResultsObjectsChangeset` properly groups `delete` changes`
    ///
    func testDeleteChangesAreProperlyGrouped() {
        let sampleChanges = newSampleObjectsChanges()
        let changeset = ResultsObjectsChangeset(objectChanges: sampleChanges)

        for change in sampleChanges {
            switch change {
            case .insert(let indexPath):
                XCTAssert(changeset.inserted.contains(indexPath))
            case .delete(let indexPath):
                XCTAssert(changeset.deleted.contains(indexPath))
            case .move(let oldIndexPath, let newIndexPath):
                XCTAssert(changeset.deleted.contains(oldIndexPath))
                XCTAssert(changeset.inserted.contains(newIndexPath))
            case .update(let indexPath):
                XCTAssert(changeset.updated.contains(indexPath))
            }
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
}
