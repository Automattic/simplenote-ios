import XCTest

extension XCUIApplication {

    func isDeviceIPhone8Plus(_ device: XCUIDevice = .shared) -> Bool {
        let iPhone8PlusScreenHeight = CGFloat(736)

        let frame = windows.element(boundBy: 0).frame

        switch device.orientation {
        case .landscapeLeft, .landscapeRight: return frame.width == iPhone8PlusScreenHeight
        case _: return frame.height == iPhone8PlusScreenHeight
        }
    }
}
