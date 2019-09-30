import Foundation
import UIKit


// MARK: - UISearchBar Simplenote Methods
//
extension UISearchBar {

    /// Applies Simplenote's Style
    ///
    @objc
    func applySimplenoteStyle() {
        let bgImage = UIImage()
        let bgColor = UIColor.color(name: .backgroundColor)?.withAlphaComponent(Constants.backgroundAlpha)
        let searchIconColor = UIColor.color(name: .simplenoteSlateGrey)
        let searchIconImage = UIImage.image(name: .searchIconImage)?.withOverlayColor(searchIconColor)

        backgroundColor = bgColor
        setBackgroundImage(bgImage, for: .any, barMetrics: .default)

        setImage(searchIconImage, for: .search, state: .normal)
        setSearchFieldBackgroundImage(.searchBarBackgroundImage, for: .normal)

        // Apply font to search field by traversing subviews
        for textField in subviewsOfType(UITextField.self) {
            textField.font = .preferredFont(forTextStyle: .body)
            textField.textColor = .color(name: .textColor)
            textField.keyboardAppearance = SPUserInterface.isDark ? .dark : .default
        }
    }
}


// MARK: - Constants
//
private enum Constants {

    /// SearchBar's Background Alpha, so that it matches with the navigationBar!
    ///
    static let backgroundAlpha = CGFloat(0.9)
}
