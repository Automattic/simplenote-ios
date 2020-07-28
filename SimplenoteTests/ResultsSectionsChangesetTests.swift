import XCTest
@testable import Simplenote


// MARK: - ResultsSectionsChangesetTests
//
class ResultsSectionsChangesetTests: XCTestCase {

    /// Verifies that `ResultsSectionsChangeset.transposed` translates (all of the OPs) of a given changeset to the specified section
    ///
    func testTransposedMovesChangesetsToTheSpecifiedSection() {
        var changeset = ResultsSectionsChangeset()
        changeset.deletedSection(at: .zero)
        changeset.insertedSection(at: .zero)

        let transposed = changeset.transposed(toSection: 42)

        XCTAssertEqual(transposed.deleted.count, changeset.deleted.count)
        XCTAssertEqual(transposed.inserted.count, changeset.inserted.count)
        XCTAssertEqual(transposed.deleted.first, 42)
        XCTAssertEqual(transposed.inserted.first, 42)
    }
}
