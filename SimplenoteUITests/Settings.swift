import XCTest

let screenName = "Settings"

class Settings {

    enum Elements: String {

        case doneButton = "Done"
        case condensedModeSwitch = "Condensed Note List"

        var element: XCUIElement {
            switch self {
            case .doneButton:
                return app.navigationBars[screenName].buttons[self.rawValue]
            case .condensedModeSwitch:
                return app.tables.cells.containing(.staticText, identifier: self.rawValue).firstMatch
            }
        }
    }

    static func condensedModeEnable() {
        switchCondensedModeIfNeeded(value: "1")
    }

    static func condensedModeDisable() {
        switchCondensedModeIfNeeded(value: "0")
    }

    static func switchCondensedModeIfNeeded(value: String) {
        toggleSwitchIfNeeded(Elements.condensedModeSwitch.element, value)
    }

    static func close() {
        Elements.doneButton.element.tap()
    }

    static func open() {
        Sidebar.open()
        Sidebar.getButtonSettings().tap()
    }
}
