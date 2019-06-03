//
//  VSTheme+Keys.swift
//  Simplenote
//
//  Copyright © 2019 Automattic. All rights reserved.
//

import Foundation


// MARK: - ThemeKey represents all of the available Keys for the current theme.
//
enum ThemeKey: String {
    case backgroundColor
    case noteCellBackgroundSelectionColor
    case tableViewTextLabelColor
    case tableViewDetailTextLabelColor
}


// MARK: - Public Methods
//
extension VSTheme {

    /// Returns the color associated to a given Key
    ///
    func color(forKey key: ThemeKey) -> UIColor? {
        return color(forKey: key.rawValue)
    }
}
