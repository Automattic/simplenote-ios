import UIKit

// MARK: - ApplicationStateProvider
//
extension UIApplication: ApplicationStateProvider {

}

extension UIApplication {
    @objc
    var keyWindowStatusBarHeight: CGSize {
        guard let keyWindow = windows.first(where: { $0.isKeyWindow }) else {
            return .zero
        }

        return keyWindow.windowScene?.statusBarManager?.statusBarFrame.size ?? .zero
    }
}

extension UIApplication {
    static var isRTL: Bool {
        return shared.userInterfaceLayoutDirection == .rightToLeft
    }
}
