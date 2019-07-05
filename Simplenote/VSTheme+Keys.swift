import Foundation


// MARK: - ThemeKey represents all of the available Keys for the current theme.
//
enum ThemeKey: String {
    case backgroundColor
    case noteBodyFontPreviewColor
    case noteBodyLineHeightPercentage
    case noteCellBackgroundSelectionColor
    case noteHeadlineFontColor
    case tableViewTextLabelColor
    case tableViewDetailTextLabelColor
    case tintColor
}


// MARK: - Public Methods
//
extension VSTheme {

    /// Returns the color associated to a given Key
    ///
    func color(forKey key: ThemeKey) -> UIColor? {
        return color(forKey: key.rawValue)
    }

    /// Returns the Float Value associated to a given ThemeKey
    ///
    func float(forKey key: ThemeKey) -> CGFloat {
        return float(forKey: key.rawValue)
    }
}
