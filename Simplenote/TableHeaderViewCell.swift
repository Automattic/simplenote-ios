import UIKit

// MARK: - TableHeaderViewCell
//
final class TableHeaderViewCell: UITableViewCell {
    private let titleLabel = UILabel()

    /// Wraps the TitleLabel's Text Property
    ///
    var title: String? {
        get {
            titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }

    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("Unsupported Initializer")
    }
}

// MARK: - Private API(s)
//
private extension TableHeaderViewCell {
    func configure() {
        contentView.addFillingSubview(titleLabel,
                                      edgeInsets: Constants.titleLabelExtraInsets,
                                      target: .layoutMargins)
        separatorInset = .zero
        selectionStyle = .none
        accessoryType = .none

        reloadBackgroundStyles()
        reloadTextStyles()
    }

    func reloadBackgroundStyles() {
        backgroundColor = .clear
    }

    func reloadTextStyles() {
        titleLabel.textColor = .simplenoteSecondaryTextColor
        titleLabel.font = UIFont.preferredFont(for: .subheadline, weight: .regular)
    }
}

private struct Constants {
    static let titleLabelExtraInsets = UIEdgeInsets(top: 8, left: 0, bottom: -2, right: 0)
}
