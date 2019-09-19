import Foundation


// MARK: - UINavigationBar Simplenote Methods
//
extension UINavigationBar {

    /// Applies the Simplenote *LIGHT* Style
    ///
    func applySimplenoteLightStyle() {
        /// ## Notes:
        ///
        /// ### iOS <11:
        /// An empty image causes UIKit to determine that the navigationBar's height is zero. Hence, you need to deal with the lack of safeLayoutGuide
        /// (and fallback to topLayoutGuide)... and disable edgesForExtendedLayout.
        ///
        /// This way we avoid any glitches related to the push animation + lack of shadow in the NavigationBar section.
        ///
        /// ### iOS >=11
        /// This just works, and the world is a happier place.
        ///
        barTintColor = .white
        shadowImage = UIImage()
        setBackgroundImage(UIImage(), for: .default)
    }
}
