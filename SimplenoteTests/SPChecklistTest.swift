//
//  SPChecklistTest.swift
//  SimplenoteTests
//

import XCTest

class SPChecklistTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRegexOnlyCapturesNewlines() {
        let inlineChecklist = "This is a badly formed todo - [ ] Buy avocados"
        
        let regex = try! NSRegularExpression.init(pattern: CheckListRegExPattern, options: NSRegularExpression.Options.anchorsMatchLines)
        
        let matches = regex.matches(in: inlineChecklist, options: [], range: NSMakeRange(0, inlineChecklist.count))
        
        XCTAssertTrue(matches.count == 0)
    }
    
    func testMatchProperlyFormattedChecklistSyntax() {
        let inlineChecklist = "ToDo\n\n- [ ] Buy avocados\n- [ ] Ship it\n- [x ] Malformed!\n- [x] Correct."
        
        let regex = try! NSRegularExpression.init(pattern: CheckListRegExPattern, options: NSRegularExpression.Options.anchorsMatchLines)
        
        let matches = regex.matches(in: inlineChecklist, options: [], range: NSMakeRange(0, inlineChecklist.count))
        
        XCTAssertTrue(matches.count == 3)
    }

}
