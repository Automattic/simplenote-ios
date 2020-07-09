import XCTest
@testable import Simplenote


// MARK: - ResultsSectionsChangesetTests
//
class ResultsSectionsChangesetTests: XCTestCase {

    /// Verifies that `ResultsSectionsChangeset` properly groups `ResultsSectionChange` entities into the right collections.
    ///
    func testSectionChangesetsAreProperlyGroupedIntoTheRightCollections() {
        let changes = newSampleSectionChanges()
        let changeset = ResultsSectionsChangeset(sectionChanges: changes)
        let deleted = extractDeletedSections(from: changes)
        let inserted = extractInsertedSections(from: changes)

        XCTAssertEqual(changeset.inserted, IndexSet(inserted))
        XCTAssertEqual(changeset.deleted, IndexSet(deleted))
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

    func extractDeletedSections(from changes: [ResultsSectionChange]) -> [Int] {
        return changes.compactMap { change -> Int? in
            guard case let .delete(sectionIndex) = change else {
                return nil
            }

            return sectionIndex
        }
    }

    func extractInsertedSections(from changes: [ResultsSectionChange]) -> [Int] {
        return changes.compactMap { change -> Int? in
            guard case let .insert(sectionIndex) = change else {
                return nil
            }

            return sectionIndex
        }
    }
}
