import UIKit

/// A UITableViewCell with it's `accessoryView` set to a `UISwitch`
/// Styled for Simplenote
class SwitchTableViewCell: UITableViewCell {

    /// A switch that is assigned to `accessoryView`
    var cellSwitch = UISwitch()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSwitch()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /// Styles `cellSwitch` and adds it to the view
    func setupSwitch() {
        accessoryView = cellSwitch
        cellSwitch.onTintColor = .simplenoteSwitchOnTintColor
        cellSwitch.tintColor = .simplenoteSwitchTintColor
    }
}
