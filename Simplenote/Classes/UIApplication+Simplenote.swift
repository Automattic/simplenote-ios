import UIKit

// MARK: - ApplicationStateProvider
//
extension UIApplication: ApplicationStateProvider {

}

extension UIApplication {
    static var isRTL: Bool {
        return shared.userInterfaceLayoutDirection == .rightToLeft
    }
}
