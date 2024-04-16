import Foundation
import UIKit

// MARK: - Value1TableViewCell
//
class Value1TableViewCell: UITableViewCell {

    /// Indicates if the row is Selectable
    ///
    var selectable: Bool = true {
        didSet {
            reloadTextStyles()
        }
    }

    /// Indicates if the row has clear background
    ///
    var hasClearBackground = false {
        didSet {
            if oldValue != hasClearBackground {
                reloadBackgroundStyles()
            }
        }
    }

    /// Wraps the TextLabel's Text Property
    ///
    var title: String? {
        get {
            textLabel?.text
        }
        set {
            textLabel?.text = newValue
        }
    }

    /// Wraps the DetailTextLabel's Text Property
    ///
    var value: String? {
        get {
            detailTextLabel?.text
        }
        set {
            detailTextLabel?.text = newValue
        }
    }

    /// Image tint color
    ///
    var imageTintColor: UIColor? {
        didSet {
            if oldValue != imageTintColor {
                reloadTextStyles()
            }
        }
    }

    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        reloadBackgroundStyles()
        reloadTextStyles()
    }

    required init?(coder: NSCoder) {
        fatalError("Unsupported Initializer")
    }

    // MARK: - Overriden

    override func prepareForReuse() {
        super.prepareForReuse()
        selectable = true
        accessoryType = .none
    }
}

// MARK: - Private API(s)
//
private extension Value1TableViewCell {

    func reloadBackgroundStyles() {
        let selectedView = UIView(frame: bounds)
        selectedView.backgroundColor = .simplenoteLightBlueColor

        backgroundColor = hasClearBackground ? .clear : .simplenoteTableViewCellBackgroundColor
        selectedBackgroundView = selectedView
    }

    func reloadTextStyles() {
        let textColor: UIColor = selectable ? .simplenoteTextColor : .simplenotePlaceholderTextColor
        let detailTextColor: UIColor = selectable ? .simplenoteSecondaryTextColor : .simplenotePlaceholderTextColor
        textLabel?.textColor = textColor
        detailTextLabel?.textColor = detailTextColor
        imageView?.tintColor = imageTintColor ?? textColor
        selectionStyle = selectable ? .default : .none
    }
}
