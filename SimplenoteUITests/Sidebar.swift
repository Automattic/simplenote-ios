import XCTest

class Sidebar {

	class func getButtonSettings() -> XCUIElement {
		let predicate = NSPredicate(format: "identifier == '\(UID.Cell.settings)'")
		return app.tables.cells.element(matching: predicate)
	}

	class func getButtonTagsEdit() -> XCUIElement {
		// Returning first match, because there are two 'Done' buttons
		// for some reason, having same coordinates...
		return app.tables.buttons[UID.Button.edit].firstMatch
	}

	class func getButtonTagsDone() -> XCUIElement {
		// Returning first match, because there are two 'Done' buttons
		// for some reason, having same coordinates...
		return app.tables.buttons[UID.Button.done].firstMatch
	}

	class func isOpen() -> Bool {
		// Checking for 'isHittable' of Settings button, because Settings button
		// is actually shown even when Sidebar is closed, but has the negative coords.
		// This is the property used to determine if Sidebar is open
		return Sidebar.getButtonSettings().isHittable
	}

	class func open() {
		guard !Sidebar.isOpen() else { return }
		let menuButton = app.navigationBars.element.buttons[UID.Button.menu]
		guard menuButton.exists else { return }
		menuButton.tap()
	}

	class func tagSelect(tagName: String) {
		Sidebar.open()
		let tagCell = app.tables.cells[tagName]
		guard tagCell.isHittable else { return }
		print(">>> Selecting tag: \(tagName)")
		print(app.debugDescription)
		tagCell.tap()
	}

	class func tagsEditStart() {
		let editButton = Sidebar.getButtonTagsEdit()
		guard editButton.exists else { return }
		editButton.tap()
	}

	class func tagsEditStop() {
		let doneButton = Sidebar.getButtonTagsDone()
		guard doneButton.exists else { return }
		doneButton.tap()
	}

	class func tagsDeleteAll() {
		Sidebar.tagsEditStart()

		while app.tables.buttons[UID.Button.itemTrash].firstMatch.isHittable {
			app.tables.buttons[UID.Button.itemTrash].firstMatch.tap()
			sleep(1)
			app.sheets.buttons[UID.Button.deleteTagConfirmation].tap()
			sleep(1)
		}

		Sidebar.tagsEditStop()
	}
}
