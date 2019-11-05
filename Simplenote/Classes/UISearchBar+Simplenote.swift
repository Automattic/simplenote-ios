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
            textField.font = .preferredFont(forTextStyle: .body)
            textField.textColor = .color(name: .textColor)
            textField.keyboardAppearance = SPUserInterface.isDark ? .dark : .default
        }
    }
}
