import XCTest

let app = XCUIApplication()
private var stepIndex = 0

func trackTest(_ function: String = #function) {
    print("> Test: \(function)")
    stepIndex = 1
}

func trackStep() {
    print(">> Step \(stepIndex)")
    stepIndex += 1
}

class Alert {

    class func closeAny() {
        let alert = app.alerts.element
        guard alert.exists else { return }

        let confirmPredicate = NSPredicate(format: "label == '" + UID.Button.accept + "' || label == 'AnythingElse'")
        let confirmationButton = alert.buttons.element(matching: confirmPredicate)
        guard confirmationButton.exists else { return }

        confirmationButton.tap()
    }
}

extension XCUIElement {
    func tapCenterCoordinates(in app: XCUIApplication) {
        let coordinates = app.coordinate(withNormalizedOffset: .zero)
            .withOffset(CGVector(dx: frame.midX, dy: frame.midY))
        coordinates.tap()
    }
}
