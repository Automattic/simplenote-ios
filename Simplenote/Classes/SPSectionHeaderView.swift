import Foundation
import UIKit


// MARK: - SPSectionHeaderView
//
@objcMembers
class SPSectionHeaderView: UITableViewHeaderFooterView {

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


    // MARK: - Overridden Methods

    override func awakeFromNib() {
        super.awakeFromNib()
        refreshStyle()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        refreshStyle()
    }
}


// MARK: - Private Methods: Skinning
//
private extension SPSectionHeaderView {

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
