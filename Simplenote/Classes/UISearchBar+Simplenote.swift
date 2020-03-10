import Foundation
import UIKit


// MARK: - UISearchBar Simplenote Methods
//
extension UISearchBar {

    /// Applies Simplenote's Style
    ///
    @objc
    func applySimplenoteStyle() {
        backgroundColor = .clear
        setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        setSearchFieldBackgroundImage(.searchBarBackgroundImage, for: .normal)

        // Apply font to search field by traversing subviews
        for textField in subviewsOfType(UITextField.self) {
            textField.font = .systemFont(ofSize: 17.0)
            textField.textColor = .simplenoteTextColor
            textField.keyboardAppearance = SPUserInterface.isDark ? .dark : .default
        }
    }
}
