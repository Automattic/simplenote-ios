import Foundation
import XCTest
@testable import Simplenote


// MARK: - NSPredicate+Simplenote Unit Tests
//
class NSPredicateSimplenoteTests: XCTestCase {

    /// Verifies that `NSPredicate.predicateForNotes(searchText:)` match entities that contain a single specified keyword
    ///
    func testPredicatesForNotesWithSearchTextMatchesNotesContainingTheSpecifiedKeyword() {
        let entity = MockupNote()
        entity.content = "some content here and maybe a keyword"

        let predicate = NSPredicate.predicateForNotes(searchText: "keyword")
        XCTAssertTrue(predicate.evaluate(with: entity))
    }

    /// Verifies that `NSPredicate.predicateForNotes(searchText:)` produces one subpredicate per word, and disregards newlines and spaces
    ///
    func testPredicatesForNotesWithSearchTextProducesOnePredicatePerWordAndDisregardNewlinesAndSpaces() {
        let keyword = "     lots of empty spaces   \n   \n  "
        let numberOfWords = 4
        let predicate = NSPredicate.predicateForNotes(searchText: keyword) as! NSCompoundPredicate

        XCTAssertTrue(predicate.subpredicates.count == numberOfWords)
    }

    /// Verifies that `NSPredicate.predicateForNotes(searchText:)` match entities that contain multiple specified keywords
    ///
    func testPredicatesForNotesWithSearchTextMatchesNotesContainingMultipleSpecifiedKeywords() {
        let entity = MockupNote()
        entity.content = "some keyword1 here and maybe another keyword2 there"

        let predicate = NSPredicate.predicateForNotes(searchText: "keyword1 keyword2")
        XCTAssertTrue(predicate.evaluate(with: entity))
    }

    /// Verifies that `NSPredicate.predicateForNotes(searchText:)` won't match entities that dont contain a given searchText
    ///
    func testPredicatesForNotesWithSearchTextWontMatchNotesContainingTheSpecifiedKeywords() {
        let entity = MockupNote()
        entity.content = "some content here and maybe a keyword"

        let predicate = NSPredicate.predicateForNotes(searchText: "missing")
        XCTAssertFalse(predicate.evaluate(with: entity))
    }

    /// Verifies that `NSPredicate.predicateForNotes(deleted:)` matches notes with a Deleted status
    ///
    func testPredicateForNotesWithDeletedStatusMatchesDeletedNotes() {
        let entity = MockupNote()
        entity.deleted = true
        XCTAssertTrue(NSPredicate.predicateForNotes(deleted: true).evaluate(with: entity))
        XCTAssertFalse(NSPredicate.predicateForNotes(deleted: false).evaluate(with: entity))
    }

    /// Verifies that `NSPredicate.predicateForNotes(deleted:)` matches notes with a Not Deleted status
    ///
    func testPredicateForNotesWithoutDeletedStatusMatchesDeletedNotes() {
        let entity = MockupNote()
        entity.deleted = false
        XCTAssertTrue(NSPredicate.predicateForNotes(deleted: false).evaluate(with: entity))
        XCTAssertFalse(NSPredicate.predicateForNotes(deleted: true).evaluate(with: entity))
    }

    /// Verifies that `NSPredicate.predicateForNotes(systemTag:)` properly matches entities that contain a given systemTag
    ///
    func testPredicateForNotesWithSystemTagMatchesEntitiesThatContainTheTargetSystemTag() {
        let systemTag = "pinned"
        let entity = MockupNote()
        entity.systemTags = systemTag
        XCTAssertTrue(NSPredicate.predicateForNotes(systemTag: systemTag).evaluate(with: entity))
    }

    /// Verifies that `NSPredicate.predicateForNotes(systemTag:)` will not match entities that dont contain a given systemTag
    ///
    func testPredicateForNotesWithSystemTagDoesntMatchEntitiesThatContainTheTargetSystemTag() {
        let systemTag = "pinned"
        let entity = MockupNote()
        XCTAssertFalse(NSPredicate.predicateForNotes(systemTag: systemTag).evaluate(with: entity))
    }

    /// Verifies that `NSPredicate.predicateForNotes(tag:)` matches JSON Arrays that contain a single value, matching our target
    ///
    func testPredicateForNotesWithTagProperlyMatchesEntitiesThatContainSingleTags() {
        let tag = "Yosemite"
        let entity = MockupNote()
        entity.tags = "[ \"" + tag + "\"]"
        XCTAssertTrue(NSPredicate.predicateForNotes(tag: tag).evaluate(with: entity))
    }

    /// Verifies that `NSPredicate.predicateForNotes(tag:)` matches JSON Arrays that contain multiple values, one of them being our target
    ///
    func testPredicateForNotesWithTagProperlyMatchesEntitiesThatContainMultipleTags() {
        let tag = "Yosemite"
        let entity = MockupNote()
        entity.tags = "[ \"second\", \"third\", \"" + tag + "\" ]"
        XCTAssertTrue(NSPredicate.predicateForNotes(tag: tag).evaluate(with: entity))
    }

    /// Verifies that `NSPredicate.predicateForNotes(tag:)` properly deals with slashes
    ///
    func testPredicateForNotesWithTagProperlyHandlesTagsWithSlashes() {
        let tag = "\\Yosemite"
        let entity = MockupNote()
        entity.tags = "[ \"\\\\Yosemite\" ]"
        XCTAssertTrue(NSPredicate.predicateForNotes(tag: tag).evaluate(with: entity))
    }

    /// Verifies that `NSPredicate.predicateForNotes(tag:)` won't produce matches for entities that do not contain the target Tag
    ///
    func testPredicateForNotesWithTagTagDoesntMatchEntitiesThatDontContainTheTargetTag() {
        let tag = "Missing"
        let entity = MockupNote()
        entity.tags = "[ \"Tag\" ]"
        XCTAssertFalse(NSPredicate.predicateForNotes(tag: tag).evaluate(with: entity))
    }

    /// Verifies that `NSPredicate.predicateForUntaggedNotes` matches a perfectly formed empty JSON Array
    ///
    func testPredicateForUntaggedNotesMatchesEmptyJsonArrays() {
        let entity = MockupNote()
        entity.tags = "[]"
        XCTAssertTrue(NSPredicate.predicateForUntaggedNotes().evaluate(with: entity))
    }

    /// Verifies that `NSPredicate.predicateForUntaggedNotes` matches a JSON Array with random spaces
    ///
    func testPredicateForUntaggedNotesMatchesEmptyJsonArraysWithRandomSpaces() {
        let entity = MockupNote()
        entity.tags = "    [ ] "
        XCTAssertTrue(NSPredicate.predicateForUntaggedNotes().evaluate(with: entity))
    }

    /// Verifies that `NSPredicate.predicateForUntaggedNotes` matches empty strings
    ///
    func testPredicateForUntaggedNotesMatchesEmptyStrings() {
        let entity = MockupNote()
        entity.tags = ""
        XCTAssertTrue(NSPredicate.predicateForUntaggedNotes().evaluate(with: entity))
    }

    /// Verifies that `NSPredicate.predicateForUntaggedNotes` won't match a non empty JSON Array
    ///
    func testPredicateForUntaggedNotesWontMatchNonEmptyJsonArrays() {
        let entity = MockupNote()
        entity.tags = "[\"tag\"]"
        XCTAssertFalse(NSPredicate.predicateForUntaggedNotes().evaluate(with: entity))
    }

    /// Verifies that `NSPredicate.predicateForTag(name:)` matches Tags with names containing the specified name (partially or fully)
    ///
    func testPredicateForTagWithNameMatchesEntitiesWithTheTargetName() {
        let entity = MockupTag()
        entity.name = "123456789"
        XCTAssertTrue(NSPredicate.predicateForTag(name: entity.name!).evaluate(with: entity))
        XCTAssertTrue(NSPredicate.predicateForTag(name: "45").evaluate(with: entity))
    }

    /// Verifies that `NSPredicate.predicateForTag(name:)` won't match Tags that don't contain a given string
    ///
    func testPredicateForTagWithNameWontMatcheEntitiesWithoutTheTargetName() {
        let entity = MockupTag()
        entity.name = "123456789"
        XCTAssertFalse(NSPredicate.predicateForTag(name: "0").evaluate(with: entity))
    }
}


// MARK: - MockupNote: Convenience class to help us test NSPredicate(s)
//
@objcMembers
private class MockupNote: NSObject {

    /// Entity's Contents
    ///
    dynamic var content: String?

    /// Deletion Status
    ///
    dynamic var deleted = false

    /// Entity's System Tags
    ///
    dynamic var systemTags: String?

    /// Entity's Tags
    ///
    dynamic var tags: String?
}


// MARK: - MockupTag: Convenience class to help us test NSPredicate(s)
//
@objcMembers
private class MockupTag: NSObject {

    /// Entity's System Tags
    ///
    dynamic var name: String?
}
