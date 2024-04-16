import Foundation

// MARK: - UINavigationBar + Appearance
//
extension UINavigationBar {

    /// Applies the Simplenote Appearance to `UINavigationBar` instances
    ///
    class func refreshAppearance() {
        let clearImage = UIImage()
        let apperance = UINavigationBar.appearance(whenContainedInInstancesOf: [SPNavigationController.self])

        apperance.barTintColor = .clear
        apperance.shadowImage = clearImage
        apperance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold),
            .foregroundColor: UIColor.simplenoteNavigationBarTitleColor
        ]
        apperance.setBackgroundImage(clearImage, for: .default)
        apperance.setBackgroundImage(clearImage, for: .defaultPrompt)
    }
}
