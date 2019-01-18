//
//  SPChecklistTest.swift
//  SimplenoteTests
//

import XCTest

class SPChecklistTest: XCTestCase {
    func testChecklistShouldNotRenderWithinText() {
        let inlineChecklist = "This is a badly formed todo - [ ] Buy avocados"
        
        let regex = try! NSRegularExpression(pattern: CheckListRegExPattern, options: NSRegularExpression.Options.anchorsMatchLines)
        
        let matches = regex.matches(in: inlineChecklist, options: [], range: NSMakeRange(0, inlineChecklist.count))
        
        XCTAssertTrue(matches.count == 0)
    }
    
    func testChecklistRenderWithPrefixedWhitespace() {
        let inlineChecklist = "       - [ ] Buy avocados - [ ] "
        
        let regex = try! NSRegularExpression(pattern: CheckListRegExPattern, options: NSRegularExpression.Options.anchorsMatchLines)
        
        let matches = regex.matches(in: inlineChecklist, options: [], range: NSMakeRange(0, inlineChecklist.count))
        
        XCTAssertTrue(matches.count == 1)
    }
    
    func testMatchProperlyFormattedChecklistSyntax() {
        let inlineChecklist = "ToDo\n\n- [ ] Buy avocados\n- [ ] Ship it\n- [x ] Malformed!\n- [x] Correct."
        
        let regex = try! NSRegularExpression(pattern: CheckListRegExPattern, options: NSRegularExpression.Options.anchorsMatchLines)
        
        let matches = regex.matches(in: inlineChecklist, options: [], range: NSMakeRange(0, inlineChecklist.count))
        
        XCTAssertTrue(matches.count == 3)
    }

}
