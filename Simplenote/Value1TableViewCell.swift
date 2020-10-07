import Foundation
import UIKit


// MARK: - Value1TableViewCell
//
class Value1TableViewCell: UITableViewCell {

    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        reloadStyles()
    }

    required init?(coder: NSCoder) {
        fatalError("Unsupported Initializer")
    }
}


// MARK: - Private API(s)
//
private extension Value1TableViewCell {

    func reloadStyles() {
        let selectedView = UIView(frame: bounds)
        selectedView.backgroundColor = .simplenoteLightBlueColor

        backgroundColor = .simplenoteTableViewCellBackgroundColor
        selectedBackgroundView = selectedView

        textLabel?.textColor = .simplenoteTextColor
        detailTextLabel?.textColor = .simplenoteSecondaryTextColor
    }
}
