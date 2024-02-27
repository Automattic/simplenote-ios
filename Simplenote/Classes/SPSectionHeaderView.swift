import Foundation
import UIKit

// MARK: - SPSectionHeaderView
//
@objcMembers
class SPSectionHeaderView: UITableViewHeaderFooterView {

    /// View Containing all of the subviews
    ///
    @IBOutlet private var containerView: UIView!

    /// Override `textLabel` to add `@IBOutlet` annotation
    ///
    @IBOutlet override var textLabel: UILabel? {
        get {
            return _textLabel
        }
        set {
            _textLabel = newValue
        }
    }

    private var _textLabel: UILabel?

    /// We're simply unable to build a TableVIewHeaderFooter, in IB, without triggering warnings about the contentView.
    /// SO: We're just loading a nib with the hieararchy we want, and manually attaching the top level container
    ///
    private lazy var nib = UINib(nibName: type(of: self).classNameWithoutNamespaces, bundle: nil)

    // MARK: - Overridden Methods

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureSubviews()
        refreshStyle()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureSubviews()
        refreshStyle()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        refreshStyle()
    }
}

// MARK: - Private Methods
//
private extension SPSectionHeaderView {

    /// Sets up the Subviews / Layout
    ///
    func configureSubviews() {
        nib.instantiate(withOwner: self, options: nil)
        contentView.addSubview(containerView)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    /// Refreshes the current Style current style
    ///
    func refreshStyle() {
        // Setting contentView.backgroundColor would be easier, but oh well, that triggers a console warning.
        let bgView = UIView()
        bgView.backgroundColor = .simplenoteTableViewHeaderBackgroundColor
        backgroundView = bgView

        textLabel?.textColor = .simplenoteTextColor
        textLabel?.font = UIFont.preferredFont(for: .body, weight: .semibold)
    }
}
