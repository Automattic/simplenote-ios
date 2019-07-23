//
//  SPDefaultTableViewCell.swift
//  Simplenote
//
//  Copyright © 2019 Automattic. All rights reserved.
//

import Foundation


// MARK: - UITableViewCell with the `.default` Style
//
class SPDefaultTableViewCell: UITableViewCell {

    /// UITableView's Reusable Identifier
    ///
    static let reusableIdentifier = "SPDefaultTableViewCell"

    /// Designated Initializer
    ///
    init() {
        super.init(style: .default, reuseIdentifier: SPDefaultTableViewCell.reusableIdentifier)
        applySimplenoteStyle()
    }

    /// Required Initializer
    ///
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        applySimplenoteStyle()
    }
}


// MARK: - Private
//
private extension SPDefaultTableViewCell {

    func applySimplenoteStyle() {
        let theme = VSThemeManager.shared().theme()

        let backgroundView = UIView()
        backgroundView.backgroundColor = theme.color(forKey: .noteCellBackgroundSelectionColor)

        backgroundColor = theme.color(forKey: .backgroundColor)
        selectedBackgroundView = backgroundView
        detailTextLabel?.textColor = theme.color(forKey: .tableViewDetailTextLabelColor)
        textLabel?.textColor = theme.color(forKey: .tableViewTextLabelColor)
    }
}
