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
        let backgroundView = UIView()
        backgroundView.backgroundColor = .simplenoteLightBlueColor

        backgroundColor = .simplenoteTableViewCellBackgroundColor
        selectedBackgroundView = backgroundView
        detailTextLabel?.textColor = .simplenoteSecondaryTextColor
        textLabel?.textColor = .simplenoteTextColor
    }
}
