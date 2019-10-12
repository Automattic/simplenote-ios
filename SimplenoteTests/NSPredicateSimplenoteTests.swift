import Foundation
import XCTest
@testable import Simplenote


// MARK: - NSPredicate+Simplenote Unit Tests
//
class NSPredicateSimplenoteTests: XCTestCase {


    /// Verifies that `NSPredicate.predicateForUntaggedNotes` matches a perfectly formed empty JSON Array
    ///
    func testPredicateForUntaggedNotesMatchesEmptyJsonArrays() {
        let entity = MockupEntity()
        entity.tags = "[]"
        XCTAssertTrue(NSPredicate.predicateForUntaggedNotes().evaluate(with: entity))
    }

    /// Verifies that `NSPredicate.predicateForUntaggedNotes` matches a JSON Array with random spaces
    ///
    func testPredicateForUntaggedNotesMatchesEmptyJsonArraysWithRandomSpaces() {
        let entity = MockupEntity()
        entity.tags = "    [ ] "
        XCTAssertTrue(NSPredicate.predicateForUntaggedNotes().evaluate(with: entity))
    }

    /// Verifies that `NSPredicate.predicateForUntaggedNotes` matches empty strings
    ///
    func testPredicateForUntaggedNotesMatchesEmptyStrings() {
        let entity = MockupEntity()
        entity.tags = ""
        XCTAssertTrue(NSPredicate.predicateForUntaggedNotes().evaluate(with: entity))
    }

    /// Verifies that `NSPredicate.predicateForUntaggedNotes` won't match a non empty JSON Array
    ///
    func testPredicateForUntaggedNotesWontMatchNonEmptyJsonArrays() {
        let entity = MockupEntity()
        entity.tags = "[\"tag\"]"
        XCTAssertFalse(NSPredicate.predicateForUntaggedNotes().evaluate(with: entity))
    }

    /// Verifies that `NSPredicate.predicateForTag` matches JSON Arrays that contain a single value, matching our target
    ///
    func testPredicateForTagMatchesJsonArraysContainingSingleTag() {
        let tag = "Yosemite"
        let entity = MockupEntity()
        entity.tags = "[ \"" + tag + "\"]"
        XCTAssertTrue(NSPredicate.predicateForTag(with: tag).evaluate(with: entity))
    }

    /// Verifies that `NSPredicate.predicateForTag` matches JSON Arrays that contain multiple values, one of them being our target
    ///
    func testPredicateForTagMatchesJsonArraysContainingMultipleTags() {
        let tag = "Yosemite"
        let entity = MockupEntity()
        entity.tags = "[ \"second\", \"third\", \"" + tag + "\" ]"
        XCTAssertTrue(NSPredicate.predicateForTag(with: tag).evaluate(with: entity))
    }

    /// Verifies that `NSPredicate.predicateForTag` properly deals with slashes
    ///
    func testPredicateForTagMatchesTagsContainingSlashes() {
        let tag = "\\Yosemite"
        let entity = MockupEntity()
        entity.tags = "[ \"\\\\Yosemite\" ]"
        XCTAssertTrue(NSPredicate.predicateForTag(with: tag).evaluate(with: entity))
    }

    /// Verifies that `NSPredicate.predicateForTag` won't produce matches for entities that do not contain the target Tag
    ///
    func testPredicateForTagDoesntMatchMissingTags() {
        let tag = "Missing"
        let entity = MockupEntity()
        entity.tags = "[ \"Tag\" ]"
        XCTAssertFalse(NSPredicate.predicateForTag(with: tag).evaluate(with: entity))
    }
}


// MARK: - MockupEntity: Convenience class to help us test NSPredicate(s)
//
private class MockupEntity: NSObject {

    /// Entity's Tags
    ///
    @objc
    dynamic var tags: String?
}
