import Foundation

// MARK: - UIBarButtonItem + Appearance
//
extension UIBarButtonItem {

    /// Applies the Simplenote Appearance to `UIBarButtonItem` instances
    ///
    class func refreshAppearance() {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.preferredFont(forTextStyle: .body)
        ]

        let appearance = UIBarButtonItem.appearance()
        appearance.setTitleTextAttributes(titleAttributes, for: .normal)
    }
}
