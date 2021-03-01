import XCTest

let notExpectedEnding = " is NOT as expected",
    notFoundEnding = " NOT found",
    notAbsentEnding = " NOT absent"

let inAllNotesEnding = " in \"All Notes\"",
    inNoteListEnding = " in \"Note List\"",
    inTrashEnding = " in \"Trash\"",
    inEditorEnding = " in Note Editor",
    inNotePreviewEnding = " in Note Preview",
    inWebViewEnding = " in WebView"

let checkboxNotFound = " checkbox" + notFoundEnding,
    checkboxNotAbsent = " checkbox" + notAbsentEnding,
    textViewNotFound = " TextView" + notFoundEnding,
    buttonNotFound = " button" + notFoundEnding,
    labelNotFound = " label" + notFoundEnding,
    labelNotAbsent = " label" + notAbsentEnding

let alertHeadingNotFound = " alert heading" + notFoundEnding,
    alertContentNotFound = " alert content" + notFoundEnding,
    alertButtonNotFound = " alert button" + notFoundEnding

let navBarNotFound = " navigation bar" + notFoundEnding,
    imageNotFound = " image" + notFoundEnding

let noteNotFoundInAllNotes = "\" Note" + notFoundEnding + inAllNotesEnding,
    noteNotAbsentInAllNotes = " Note" + notAbsentEnding + inAllNotesEnding,
    noteNotFoundInTrash = " Note" + notFoundEnding + inTrashEnding,
    noteNotAbsentInTrash = " Note" + notAbsentEnding + inTrashEnding

let numberOfNotesInAllNotesNotExpected = "Notes Number" + inAllNotesEnding + notExpectedEnding,
    numberOfNotesInTrashNotExpected = "Notes Number" + inTrashEnding + notExpectedEnding,
    numberOfTagsSuggestionsNotExpected = "Tags search suggestions " + inNoteListEnding + notExpectedEnding

let linkContainerNotFoundInEditor = "\" link container" + notFoundEnding + inEditorEnding,
    linkNotFoundInEditor = "\" link" + notFoundEnding + inEditorEnding,
    linkNotFoundInPreview = "\" link" + notFoundEnding + inNotePreviewEnding

let textNotFoundInEditor = "\" text" + notFoundEnding + inEditorEnding,
    textNotFoundInPreview = "\" text" + notFoundEnding + inNotePreviewEnding,
    textNotFoundInWebView = "\" text" + notFoundEnding + inWebViewEnding

let numberOfBoxesInPreviewNotExpected = "Boxes number" + inNotePreviewEnding + notExpectedEnding,
    numberOfCheckedBoxesInPreviewNotExpected = "Checked boxes number" + inNotePreviewEnding + notExpectedEnding,
    numberOfEmptyBoxesInPreviewNotExpected = "Empty boxes number" + inNotePreviewEnding + notExpectedEnding

let checkboxFoundMoreThanOnce = "Checkbox found more than once"
let assertNavBarIdentifier = ">>> Asserting that currenly active navigation bar is: "
let assertSearchHeaderShown = ">>> Asserting that search results header is shown: "
let assertSearchHeaderNotShown = ">>> Asserting that search results header is NOT shown: "
let foundNoNavBar = "Could not find any navigation bar"

let maxLoadTimeout = 20.0,
    minLoadTimeout = 1.0

class Assert {

    class func labelExists(labelText: String) {
        XCTAssertTrue(app.staticTexts[labelText].waitForExistence(timeout: minLoadTimeout), labelText + labelNotFound)
    }

    class func labelAbsent(labelText: String) {
        XCTAssertFalse(app.staticTexts[labelText].waitForExistence(timeout: minLoadTimeout), labelText + labelNotAbsent)
    }

    class func alertExistsAndClose(headingText: String, content: String, buttonText: String) {
        let alert = app.alerts[headingText]
        let alertHeadingExists = alert.waitForExistence(timeout: maxLoadTimeout)

        XCTAssertTrue(alertHeadingExists, headingText + alertHeadingNotFound)

        if alertHeadingExists {
            XCTAssertTrue(alert.staticTexts[content].waitForExistence(timeout: minLoadTimeout), content + alertContentNotFound)
            XCTAssertTrue(alert.buttons[buttonText].waitForExistence(timeout: minLoadTimeout), buttonText + alertButtonNotFound)
        }

        alert.buttons[buttonText].tap()
    }

    class func signUpLogInScreenShown() {
        XCTAssertTrue(app.images[UID.Picture.appLogo].waitForExistence(timeout: minLoadTimeout), UID.Picture.appLogo + imageNotFound)
        XCTAssertTrue(app.staticTexts[Text.appName].waitForExistence(timeout: minLoadTimeout), Text.appName + labelNotFound)
        XCTAssertTrue(app.staticTexts[Text.appTagline].waitForExistence(timeout: minLoadTimeout), Text.appTagline + labelNotFound)
        XCTAssertTrue(app.buttons[UID.Button.signUp].waitForExistence(timeout: minLoadTimeout), UID.Button.signUp + buttonNotFound)
        XCTAssertTrue(app.buttons[UID.Button.logIn].waitForExistence(timeout: minLoadTimeout), UID.Button.logIn + buttonNotFound)
    }
}
