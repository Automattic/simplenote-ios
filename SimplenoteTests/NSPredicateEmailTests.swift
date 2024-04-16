import Foundation
import XCTest
@testable import Simplenote

// MARK: - NSPredicate+Email Unit Tests
//
class NSPredicateEmailTests: XCTestCase {

    /// Verifies that `predicateForEmailValidation` evaluates false whenever the input string is empty
    ///
    func testPredicateForEmailValidationEvaluatesFalseOnEmptyStrings() {
        let predicate = NSPredicate.predicateForEmailValidation()
        XCTAssertFalse(predicate.evaluate(with: ""))
    }

    /// Verifies that `predicateForEmailValidation` evaluates false whenever the input string doesn't contain `@`
    ///
    func testPredicateForEmailValidationEvaluatesFalseOnStringsWithoutAtCharacter() {
        let predicate = NSPredicate.predicateForEmailValidation()
        XCTAssertFalse(predicate.evaluate(with: "simplenote.com"))
    }

    /// Verifies that `predicateForEmailValidation` evaluates false whenever the input string is a malformed address
    ///
    func testPredicateForEmailValidationEvaluatesFalseOnMalformedEmails() {
        let predicate = NSPredicate.predicateForEmailValidation()
        XCTAssertFalse(predicate.evaluate(with: "j@j..com"))
        XCTAssertFalse(predicate.evaluate(with: "j@j.com...ar"))
        XCTAssertFalse(predicate.evaluate(with: "@test"))
        XCTAssertFalse(predicate.evaluate(with: "@test.com"))
        XCTAssertFalse(predicate.evaluate(with: "test.com"))
        XCTAssertFalse(predicate.evaluate(with: "test.test.coffee"))
    }

    /// Verifies that `predicateForEmailValidation` evaluates true when the email is well formed
    ///
    func testPredicateForEmailValidationEvaluatesTrueOnValidEmailAddresses() {
        let predicate = NSPredicate.predicateForEmailValidation()
        XCTAssertTrue(predicate.evaluate(with: "j@j.com"))
        XCTAssertTrue(predicate.evaluate(with: "something@seriouslynotrealbutvalidsimplenote.blog"))
        XCTAssertTrue(predicate.evaluate(with: "something@seriouslynotrealbutvalidsimplenote.blog.ar"))
    }

    /// Verifies that `predicateForEmailValidation` returns  *true* when the email contains a New / Non Standard TLD
    ///
    func testPredicateForEmailValidationEvaluatesTrueWhenStringContainsNewTLDs() {
        let predicate = NSPredicate.predicateForEmailValidation()
        XCTAssertTrue(predicate.evaluate(with: "test@test.coffee"))
        XCTAssertTrue(predicate.evaluate(with: "test@test.email"))
        XCTAssertTrue(predicate.evaluate(with: "test@test.education"))
    }
}
