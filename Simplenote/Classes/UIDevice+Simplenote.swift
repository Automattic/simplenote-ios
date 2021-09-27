import Foundation


// MARK: - Simplenote Methods
//
extension UIDevice {

    @objc
    static var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
}
