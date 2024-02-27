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
            textField.textColor = .simplenoteTextColor
            textField.keyboardAppearance = SPUserInterface.isDark ? .dark : .default
        }
    }

    @objc
    func refreshPlaceholderStyle(searchEnabled enabled: Bool = true) {
        for textField in subviewsOfType(UITextField.self) {
            if let text = textField.placeholder {
                let color: UIColor = enabled ? .simplenotePlaceholderTextColor : .simplenoteDisabledPlaceholderTextColor
                let attributes = [NSAttributedString.Key.foregroundColor: color]
                let attributedText = NSAttributedString(string: text, attributes: attributes)
                textField.attributedPlaceholder = attributedText
            }
        }
    }

}
