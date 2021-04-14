import XCTest

extension XCUIElement {

    public func paste(text: String) -> Void {
        let previousPasteboardContents = UIPasteboard.general.string
        UIPasteboard.general.string = text

        self.press(forDuration: 1.2)
        XCUIApplication().menuItems.firstMatch.tap()

        if let string = previousPasteboardContents {
            UIPasteboard.general.string = string
        }
    }

    /**
     Removes any current text in the field before typing in the new value
     - Parameter text: the text to enter into the field
     */
    public func clearAndEnterText(text: String) {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }

        self.tap()

        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)

        self.typeText(deleteString)
        self.typeText(text)
    }
}
