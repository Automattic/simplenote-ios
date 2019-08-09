import Foundation


// MARK: - UINavigationBar Simplenote Methods
//
extension UINavigationBar {

    /// Applies the Simplenote *LIGHT* Style
    ///
    func applySimplenoteLightStyle() {
        barTintColor = .white
        shadowImage = UIImage()
        setBackgroundImage(UIImage(), for: .default)
    }
}
