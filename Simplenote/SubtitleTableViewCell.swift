import UIKit

// MARK: - SubtitleTableViewCell
//
final class SubtitleTableViewCell: UITableViewCell {

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

    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        reloadBackgroundStyles()
        reloadTextStyles()
    }

    required init?(coder: NSCoder) {
        fatalError("Unsupported Initializer")
    }

    // MARK: - Overriden

    override func prepareForReuse() {
        super.prepareForReuse()
        accessoryType = .none
    }
}

// MARK: - Private API(s)
//
private extension SubtitleTableViewCell {

    func reloadBackgroundStyles() {
        let selectedView = UIView(frame: bounds)
        selectedView.backgroundColor = .simplenoteLightBlueColor

        backgroundColor = .clear
        selectedBackgroundView = selectedView
    }

    func reloadTextStyles() {
        let textColor: UIColor = .simplenoteTextColor
        let detailTextColor: UIColor = .simplenoteSecondaryTextColor

        textLabel?.textColor = textColor
        detailTextLabel?.textColor = detailTextColor

        textLabel?.font = UIFont.preferredFont(for: .body, weight: .regular)
        detailTextLabel?.font = UIFont.preferredFont(for: .subheadline, weight: .regular)
    }
}
