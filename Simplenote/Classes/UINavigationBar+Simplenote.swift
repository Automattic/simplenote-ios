import Foundation


// MARK: - UINavigationBar Simplenote Methods
//
extension UINavigationBar {

    /// Applies Simplenote's **LIGHT** Style
    ///
    func applyLightStyle() {
        let bcColor = UIColor.white
        backgroundColor = bcColor
        barTintColor = bcColor

        let backgroundImage = UIImage()
        shadowImage = backgroundImage
        setBackgroundImage(backgroundImage, for: .default)
        setBackgroundImage(backgroundImage, for: .defaultPrompt)
    }
}
