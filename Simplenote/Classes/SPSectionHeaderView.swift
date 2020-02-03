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
        contentView.backgroundColor = .simplenoteTableViewHeaderBackgroundColor
        textLabel?.textColor = .simplenoteTextColor
        textLabel?.font = UIFont.preferredFont(for: .body, weight: .semibold)
    }
}
