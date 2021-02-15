import XCTest

class NoteEditor {

    class func clearText() {
        app.textViews.element.clearAndEnterText(text: "")
    }

    class func clearAndEnterText(enteredValue: String) {
        app.textViews.element.clearAndEnterText(text: enteredValue)
    }

    class func getEditorText() -> String {
        return app.textViews.element.value as! String
    }

    class func setFocus() {
        app.textViews.firstMatch.tap()
    }
    
    class func undo() {
        app.textViews.element.tap(withNumberOfTaps: 2, numberOfTouches: 3)
        app.otherElements["UIUndoInteractiveHUD"].children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 1).tap()
    }

    class func swipeToPreview() {
        app.textViews.firstMatch.swipeLeft()
        sleep(1)
    }

    class func leaveEditor() {
        app.navigationBars[uidNavBar_AllNotes].buttons[uidButton_NoteEditor_AllNotes].tap()
    }

    class func toggleMarkdownState() {
        app.navigationBars[uidNavBar_AllNotes].buttons[uidButton_NoteEditor_Menu].tap()
        app.tables.staticTexts[uidText_NoteEditor_Options_Markdown].tap()
        app.navigationBars[uidNavBar_NoteEditor_Options].buttons[uidButton_Done].tap()
    }

    class func insertChecklist() {
        app.navigationBars[uidNavBar_AllNotes].buttons[uidButton_NoteEditor_Checklist].tap()
    }
    
    class func markdownEnable() {
        swipeToPreview()

        if app.navigationBars[uidNavBar_NoteEditor_Preview].exists {
            Preview.leavePreviewViaBackButton()
        } else {
            toggleMarkdownState()
        }
    }

    class func markdownDisable() {
        swipeToPreview()

        guard app.navigationBars[uidNavBar_NoteEditor_Preview].exists else { return }
        
        Preview.leavePreviewViaBackButton()
        toggleMarkdownState()
    }

    class func pressLink(containerText: String, linkifiedText: String) {
        // Should be replaced with proper way to determine if page is loaded
        app.textViews[containerText].links[linkifiedText].press(forDuration: 1.3)
        sleep(4)
    }
    
    class func getAllTextViews() -> XCUIElementQuery {
        // If we are in Note Editor, and there a zero TextViews,
        // we should try setting focus first
        if app.descendants(matching: .textView).count < 1 {
            NoteEditor.setFocus()
        }
        
        return app.descendants(matching: .textView)
    }
    
    class func getCheckboxesForTextCount(text: String) -> Int {
        let textViews = getAllTextViews()
        var matchesCounter = 0
        
        for index in 0...textViews.count - 1
        {
            let currentLabel = textViews.element(boundBy: index).label

            if currentLabel == text {
                matchesCounter += 1
            }
        }
        
        let logMsg = ">>>>>> Found " + String(matchesCounter) + " Checkboxe(s) for '" + text + "'"
        print(logMsg)
        return matchesCounter
    }
    
    class func textViewsWithExactTextCount(text: String) -> Int {
        let textViews = getAllTextViews()
        var matchesCounter = 0

        for index in 0...textViews.count - 1
        {
            let currentValue = textViews.element(boundBy: index).value as! String
            let currentValueStripped = currentValue.replacingOccurrences(of: "\u{fffc}", with: "")

            if currentValueStripped == text {
                matchesCounter += 1
            }
        }
        
        let logMsg = ">>>>>> Found " + String(matchesCounter) + " TextViews with '" + text + "' text"
        print(logMsg)
        return matchesCounter
    }
    
}

class NoteEditorAssert {

    class func linkifiedURL(containerText: String, linkifiedText: String) {
        let linkContainer = app.textViews[containerText]
        XCTAssertTrue(linkContainer.exists, "\"" + containerText + linkContainerNotFoundInEditor)
        XCTAssertTrue(linkContainer.links[linkifiedText].exists, "\"" + linkifiedText + linkNotFoundInEditor)
    }

    class func editorShown() {
        let allNotesNavBar = app.navigationBars[uidNavBar_AllNotes]

        XCTAssertTrue(allNotesNavBar.waitForExistence(timeout: minLoadTimeout), uidNavBar_AllNotes + navBarNotFound)
        XCTAssertTrue(allNotesNavBar.buttons[uidButton_NoteEditor_AllNotes].waitForExistence(timeout: minLoadTimeout), uidButton_NoteEditor_AllNotes + buttonNotFound)
        XCTAssertTrue(allNotesNavBar.buttons[uidButton_NoteEditor_Checklist].waitForExistence(timeout: minLoadTimeout), uidButton_NoteEditor_Checklist + buttonNotFound)
        XCTAssertTrue(allNotesNavBar.buttons[uidButton_NoteEditor_Information].waitForExistence(timeout: minLoadTimeout), uidButton_NoteEditor_Information + buttonNotFound)
        XCTAssertTrue(allNotesNavBar.buttons[uidButton_NoteEditor_Menu].waitForExistence(timeout: minLoadTimeout), uidButton_NoteEditor_Menu + buttonNotFound)
    }

    class func wholeTextShown(text: String) {
        XCTAssertEqual(text, NoteEditor.getEditorText(), "Note Editor text" + notExpectedEnding)
    }

    class func textViewWithExactContentShownOnce(text: String) {
        let actualTextViewsWithExactContentCount = NoteEditor.textViewsWithExactTextCount(text: text)
        XCTAssertEqual(1, actualTextViewsWithExactContentCount)
    }
        
    class func checkboxForTextShownOnce(text: String) {
        let actualCheckboxesForTextCount = NoteEditor.getCheckboxesForTextCount(text: text)
        XCTAssertEqual(1, actualCheckboxesForTextCount)
    }
    
    class func checkboxForTextNotShown(text: String) {
        let actualCheckboxesForTextCount = NoteEditor.getCheckboxesForTextCount(text: text)
        XCTAssertEqual(0, actualCheckboxesForTextCount)
    }
    
    class func substringShown(text: String) {
        let textPredicate = NSPredicate(format: "label MATCHES '" + text + "'")
        let textView = app.textViews.element(matching: textPredicate)

        XCTAssertTrue(textView.exists, "\"" + text + textNotFoundInEditor)
    }
}
