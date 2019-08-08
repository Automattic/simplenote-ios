import Foundation


// MARK: - UINavigationBar Simplenote Methods
//
extension UINavigationBar {

    /// Applies the Simplenote *LIGHT* Style
    ///
    func applySimplenoteLightStyle() {
        let solidBackgroundImage = UIImage(color: .white)

        barTintColor = .white
        shadowImage = solidBackgroundImage
        setBackgroundImage(solidBackgroundImage, for: .default)
    }
}
