//
//  Value1TableViewCell.swift
//  Simplenote
//
//  Created by Matthew Cheetham on 15/08/2020.
//  Copyright © 2020 Automattic. All rights reserved.
//

import UIKit

class Value1TableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
