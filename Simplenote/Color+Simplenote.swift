import SwiftUI

@available(iOS 13.0, *)
extension Color {
    /// Convenience initializers to get and use Simplenote color studio colors
    ///
    init(studioColor: ColorStudio, alpha: CGFloat = UIKitConstants.alpha1_0) {
        self.init(UIColor(studioColor: studioColor, alpha: alpha))
    }

    init(for colorScheme: ColorScheme, light: ColorStudio, lightAlpha: CGFloat = UIKitConstants.alpha1_0, dark: ColorStudio, darkAlpha: CGFloat = UIKitConstants.alpha1_0) {
        let color = colorScheme == .dark ? dark : light
        let alpha = colorScheme == .dark ? darkAlpha : lightAlpha
        self.init(UIColor(studioColor: color, alpha: alpha))
    }
}
