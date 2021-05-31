import XCTest

class NoteEditor {

    class func dismissKeyboard() {
        let dismissKeyboardButton = app.buttons[UID.Button.dismissKeyboard]
        guard dismissKeyboardButton.exists else { return }

        dismissKeyboardButton.tap()
    }

    class func addTag(tagName: String) {
        NoteEditor.dismissKeyboard()
        let tagInput = app.textFields[UID.TextField.tag]
        guard tagInput.exists else { return }

        print(">>> Adding tag: " + tagName)
        tagInput.tap()
        tagInput.typeText(tagName + "\n")
    }

    class func clearText() {
        app.textViews.element.clearAndEnterText(text: "")
    }

    class func clearAndEnterText(enteredValue: String, usingPaste: Bool = false) {
        let noteContentTextView = app.textViews.element

        if usingPaste {
            // Clear clipboard before usage to adress flakiness
            // that appears when it's not done
            UIPasteboard.general.strings = []

            noteContentTextView.clearText()
            noteContentTextView.paste(text: enteredValue)

            // Swipe up fast to show tags input, which disappears if pasted text is large
            // enough to push tags input off screen
            noteContentTextView.swipeUp(velocity: .fast)
        } else {
            noteContentTextView.clearAndEnterText(text: enteredValue)
        }
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
        sleep(5)
    }

    class func leaveEditor() {
        let backButton = app.navigationBars[UID.NavBar.allNotes].buttons[UID.Button.noteEditorAllNotes]
        guard backButton.exists else { return }

        backButton.tap()
    }

    class func toggleMarkdownState() {
        app.navigationBars[UID.NavBar.allNotes].buttons[UID.Button.noteEditorMenu].tap()
        app.tables.staticTexts[UID.Text.noteEditorOptionsMarkdown].tap()
        app.navigationBars[UID.NavBar.noteEditorOptions].buttons[UID.Button.done].tap()
    }

    class func insertChecklist() {
        app.navigationBars[UID.NavBar.allNotes].buttons[UID.Button.noteEditorChecklist].tap()
    }

    class func markdownEnable() {
        swipeToPreview()

        if app.navigationBars[UID.NavBar.noteEditorPreview].exists {
            Preview.leavePreviewViaBackButton()
        } else {
            toggleMarkdownState()
        }
    }

    class func markdownDisable() {
        swipeToPreview()
        guard app.navigationBars[UID.NavBar.noteEditorPreview].exists else { return }

        Preview.leavePreviewViaBackButton()
        toggleMarkdownState()
    }

    class func pressLink(containerText: String, linkifiedText: String) {
        // Should be replaced with proper way to determine if page is loaded
        app.textViews[containerText].links[linkifiedText].press(forDuration: 1.3)
        sleep(4)
    }

    class func getAllTextViews() -> XCUIElementQuery {
        // If we are in Note Editor, and there's zero TextViews, we should try setting focus first
        if app.descendants(matching: .textView).count < 1 {
            NoteEditor.setFocus()
        }

        return app.descendants(matching: .textView)
    }

    class func getCheckboxesForTextCount(text: String) -> Int {
        let matches = NoteEditor.getTextViewsWithExactLabelCount(label: text)
        print(">>> ^ Found \(matches) Checkbox(es) for '\(text)'")
        return matches
    }

    class func getTextViewsWithExactValueCount(value: String) -> Int {
        let matchingTextViews = getAllTextViews()
            .compactMap { ($0.value as? String)?.strippingUnicodeObjectReplacementCharacter() }
            .filter { $0 == value }

        let matches = matchingTextViews.count
        print(">>> Found \(matches) TextView(s) with '\(value)' value")
        return matches
    }

    class func getTextViewsWithExactLabelCount(label: String) -> Int {
        let _ = getAllTextViews()// To initialize the editor
        let predicate = NSPredicate(format: "label == '" + label + "'")
        let matchingTextViews = app.textViews.matching(predicate)
        let matches = matchingTextViews.count
        print(">>> Found \(matches) TextView(s) with '\(label)' label")
        return matches
    }

}

class NoteEditorAssert {

    class func linkifiedURL(containerText: String, linkifiedText: String) {
        let linkContainer = app.textViews[containerText]
        XCTAssertTrue(linkContainer.exists, "\"" + containerText + linkContainerNotFoundInEditor)
        XCTAssertTrue(linkContainer.links[linkifiedText].exists, "\"" + linkifiedText + linkNotFoundInEditor)
    }

    class func editorShown() {
        let allNotesNavBar = app.navigationBars[UID.NavBar.allNotes]

        XCTAssertTrue(allNotesNavBar.waitForExistence(timeout: minLoadTimeout), UID.NavBar.allNotes + navBarNotFound)
        XCTAssertTrue(allNotesNavBar.buttons[UID.Button.noteEditorAllNotes].waitForExistence(timeout: minLoadTimeout), UID.Button.noteEditorAllNotes + buttonNotFound)
        XCTAssertTrue(allNotesNavBar.buttons[UID.Button.noteEditorChecklist].waitForExistence(timeout: minLoadTimeout), UID.Button.noteEditorChecklist + buttonNotFound)
        XCTAssertTrue(allNotesNavBar.buttons[UID.Button.noteEditorInformation].waitForExistence(timeout: minLoadTimeout), UID.Button.noteEditorInformation + buttonNotFound)
        XCTAssertTrue(allNotesNavBar.buttons[UID.Button.noteEditorMenu].waitForExistence(timeout: minLoadTimeout), UID.Button.noteEditorMenu + buttonNotFound)
    }

    class func textViewWithExactValueShownOnce(value: String) {
        let matches = NoteEditor.getTextViewsWithExactValueCount(value: value)
        XCTAssertEqual(matches, 1)
    }

    class func textViewWithExactValueNotShown(value: String) {
        let matches = NoteEditor.getTextViewsWithExactValueCount(value: value)
        XCTAssertEqual(matches, 0)
    }

    class func textViewWithExactLabelShownOnce(label: String) {
        let matches = NoteEditor.getTextViewsWithExactLabelCount(label: label)
        XCTAssertEqual(matches, 1)
    }

    class func textViewWithExactLabelsShownOnce(labels: [String]) {
        for label in labels {
            NoteEditorAssert.textViewWithExactLabelShownOnce(label: label)
        }
    }

    class func checkboxForTextShownOnce(text: String) {
        let matches = NoteEditor.getCheckboxesForTextCount(text: text)
        XCTAssertEqual(matches, 1)
    }

    class func checkboxForTextNotShown(text: String) {
        let matches = NoteEditor.getCheckboxesForTextCount(text: text)
        XCTAssertEqual(matches, 0)
    }
}
