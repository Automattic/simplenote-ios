import UIKit

/// A standard `UITableViewCell` set to `value1` style
class Value1TableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        applyStyles()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /// Applies custom theming to the cell
    func applyStyles() {
        backgroundColor = .simplenoteTableViewCellBackgroundColor
        let selectedView = UIView(frame: bounds)
        selectedView.backgroundColor = .simplenoteLightBlueColor
        selectedBackgroundView = selectedView
        textLabel?.textColor = .simplenoteTextColor
        detailTextLabel?.textColor = UIColor.color(name: .tableViewDetailTextLabelColor)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        applyStyles()
        textLabel?.text = nil
        detailTextLabel?.text = nil
        accessoryView = nil
    }
}
