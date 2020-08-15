//
//  SwitchTableViewCell.swift
//  Simplenote
//
//  Created by Matthew Cheetham on 13/08/2020.
//  Copyright © 2020 Automattic. All rights reserved.
//

import UIKit

class SwitchTableViewCell: UITableViewCell {

    var cellSwitch = UISwitch()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSwitch()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setupSwitch() {
        accessoryView = cellSwitch
        cellSwitch.onTintColor = .simplenoteSwitchOnTintColor
        cellSwitch.tintColor = .simplenoteSwitchTintColor
    }
}
