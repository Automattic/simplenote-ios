import XCTest
@testable import Simplenote


// MARK: - ResultsSectionsChangesetTests
//
class ResultsSectionsChangesetTests: XCTestCase {

    /// Verifies that `ResultsSectionsChangeset` properly groups `delete` changes.
    ///
    func testDeleteChangesAreProperlyGrouped() {
        let sampleChanges = newSampleSectionChanges()
        let changeset = ResultsSectionsChangeset(sectionChanges: sampleChanges)
        let deletions: [Int] = sampleChanges.compactMap { change in
            guard case .delete(let sectionIndex) = change else {
                return nil
            }

            return sectionIndex
        }

        let uniquelDeletions = IndexSet(deletions)
        XCTAssertEqual(changeset.deleted.count, uniquelDeletions.count)
    }

    /// Verifies that `ResultsSectionsChangeset` properly groups `insert` changes.
    ///
    func testInsertChangesAreProperlyGrouped() {
        let sampleChanges = newSampleSectionChanges()
        let changeset = ResultsSectionsChangeset(sectionChanges: sampleChanges)
        let insertions: [Int] = sampleChanges.compactMap { change in
            guard case .insert(let sectionIndex) = change else {
                return nil
            }

            return sectionIndex
        }

        let uniquelInserts = IndexSet(insertions)
        XCTAssertEqual(changeset.inserted.count, uniquelInserts.count)
    }
}


// MARK: - Private Helpers
//
private extension ResultsSectionsChangesetTests {

    func newSampleSectionChanges() -> [ResultsSectionChange] {
        var changes = [ResultsSectionChange]()
        for sectionIndex in 1..<100 {
            changes.append( .insert(sectionIndex: sectionIndex) )
            changes.append( .insert(sectionIndex: sectionIndex + 1) )
            changes.append( .delete(sectionIndex: sectionIndex + 1) )
        }

        return changes
    }
}
