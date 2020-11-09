import Foundation


// MARK: - Simplenote Methods
//
extension UIDevice {

    @objc
    static var isPad: Bool {
        UI_USER_INTERFACE_IDIOM() == .pad
    }
}
