import XCTest
@testable import Simplenote


// MARK: - ResultsSectionsChangesetTests
//
class ResultsSectionsChangesetTests: XCTestCase {

    /// Verifies that `ResultsSectionsChangeset` properly groups `delete` changes`
    ///
    func testDeleteChangesAreProperlyGrouped() {
        let changeset = ResultsSectionsChangeset(sectionChanges: newSampleSectionChanges())
        let mixedDeleteChanges = changeset.deleted.contains { $0.isDelete == false }

        XCTAssertFalse(mixedDeleteChanges)
    }

    /// Verifies that `ResultsSectionsChangeset` properly groups `insert` changes`
    ///
    func testInsertChangesAreProperlyGrouped() {
        let changeset = ResultsSectionsChangeset(sectionChanges: newSampleSectionChanges())
        let mixedInsertChanges = changeset.inserted.contains { $0.isInsert == false }

        XCTAssertFalse(mixedInsertChanges)
    }
}


// MARK: - Private Helpers
//
private extension ResultsSectionsChangesetTests {

    func newSampleSectionChanges() -> [ResultsSectionChange] {
        var changes = [ResultsSectionChange]()
        for sectionIndex in 1...100 where (sectionIndex % 2 == 1) {
            changes.append( .insert(sectionIndex: sectionIndex) )
            changes.append( .delete(sectionIndex: sectionIndex) )
            changes.append( .insert(sectionIndex: sectionIndex) )
            changes.append( .insert(sectionIndex: sectionIndex + 1) )
        }

        return changes
    }
}


// MARK: - ResultsSectionChange Testing Helpers
//
private extension ResultsSectionChange {

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
}
