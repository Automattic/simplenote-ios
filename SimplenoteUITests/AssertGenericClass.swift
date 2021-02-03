//
//  AssertGenericClass.swift
//  SimplenoteUITests
//
//  Created by Sergiy Fedosov on 03.02.2021.
//  Copyright © 2021 Automattic. All rights reserved.
//

import XCTest

let notExpectedEnding = " is NOT as expected"
let notFoundEnding = " NOT found"
let notAbsentEnding = " NOT absent"

let inAllNotesEnding = " in \"All Notes\""
let inTrashEnding = " in \"Trash\""
let inEditorEnding = " in Note Editor"
let inNotePreviewEnding = " in Note Preview"
let inWebViewEnding = " in WebView"

let buttonNotFound = " button" + notFoundEnding
let labelNotFound = " label" + notFoundEnding
let labelNotAbsent = " label" + notAbsentEnding

let alertHeadingNotFound = " alert heading" + notFoundEnding
let alertContentNotFound = " alert content" + notFoundEnding
let alertButtonNotFound = " alert button" + notFoundEnding

let navBarNotFound = " navigation bar" + notFoundEnding
let imageNotFound = " image" + notFoundEnding

let noteNotFoundInAllNotes = "\" Note" + notFoundEnding + inAllNotesEnding
let noteNotAbsentInAllNotes = " Note" + notAbsentEnding + inAllNotesEnding
let noteNotFoundInTrash = " Note" + notFoundEnding + inTrashEnding
let noteNotAbsentInTrash = " Note" + notAbsentEnding + inTrashEnding

let numberOfNotesInAllNotesNotExpected = "Notes Number" + inAllNotesEnding + notExpectedEnding
let numberOfNotesInTrashNotExpected = "Notes Number" + inTrashEnding + notExpectedEnding

let linkContainerNotFoundInEditor = "\" link container" + notFoundEnding + inEditorEnding
let linkNotFoundInEditor = "\" link" + notFoundEnding + inEditorEnding
let linkNotFoundInPreview = "\" link" + notFoundEnding + inNotePreviewEnding

let textNotFoundInEditor = "\" text" + notFoundEnding + inEditorEnding
let textNotFoundInPreview = "\" text" + notFoundEnding + inNotePreviewEnding
let textNotFoundInWebView = "\" text" + notFoundEnding + inWebViewEnding

let numberOfBoxesInPreviewNotExpected = "Boxes number" + inNotePreviewEnding + notExpectedEnding
let numberOfCheckedBoxesInPreviewNotExpected = "Checked boxes number" + inNotePreviewEnding + notExpectedEnding
let numberOfEmptyBoxesInPreviewNotExpected = "Empty boxes number" + inNotePreviewEnding + notExpectedEnding

let maxLoadTimeout = 20.0
let minLoadTimeout = 1.0

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
        XCTAssertTrue(app.images[uidPicture_AppLogo].waitForExistence(timeout: minLoadTimeout), uidPicture_AppLogo + imageNotFound)
        XCTAssertTrue(app.staticTexts[text_AppName].waitForExistence(timeout: minLoadTimeout), text_AppName + labelNotFound)
        XCTAssertTrue(app.staticTexts[text_AppTagline].waitForExistence(timeout: minLoadTimeout), text_AppTagline + labelNotFound)
        XCTAssertTrue(app.buttons[uidButton_SignUp].waitForExistence(timeout: minLoadTimeout), uidButton_SignUp + buttonNotFound)
        XCTAssertTrue(app.buttons[uidButton_LogIn].waitForExistence(timeout: minLoadTimeout), uidButton_LogIn + buttonNotFound)
    }
}
