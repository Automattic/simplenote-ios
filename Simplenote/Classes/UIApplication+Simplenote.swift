import UIKit

// MARK: - ApplicationStateProvider
//
extension UIApplication: ApplicationStateProvider {

}

extension UIApplication {
    @objc
    var keyWindowStatusBarHeight: CGSize {
        guard let keyWindow = foregroundSceneWindows.first(where: { $0.isKeyWindow }) else {
            return .zero
        }

        return keyWindow.windowScene?.statusBarManager?.statusBarFrame.size ?? .zero
    }
    
    /// Convenience method to return the applications window scene that's activationState is .foregroundActive
    ///
    @objc
    public var foregroundWindowScene: UIWindowScene? {
        connectedScenes.first { $0.activationState == .foregroundActive } as? UIWindowScene
    }
    
    /// Convenience var to return the foreground scene's windows
    ///
    public var foregroundSceneWindows: [UIWindow] {
        foregroundWindowScene?.windows ?? []
    }
    
    /// Returns the first window from the current foregroundActive scene
    ///
    @objc
    public var foregroundWindow: UIWindow? {
        foregroundWindowScene?.windows.first
    }
}

extension UIApplication {
    static var isRTL: Bool {
        return shared.userInterfaceLayoutDirection == .rightToLeft
    }
}
