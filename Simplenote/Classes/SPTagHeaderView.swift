import Foundation
import UIKit

// MARK: - SPTagHeaderView
//
@objc @objcMembers
class SPTagHeaderView: UIView {

    /// Leading TitleLabel
    ///
    @IBOutlet private(set) var titleLabel: UILabel!

    /// Trailing ActionButton
    ///
    @IBOutlet private(set) var actionButton: UIButton! {
        didSet {
            actionButton.titleLabel?.adjustsFontForContentSizeCategory = true
        }
    }

    // MARK: - Overriden Methods

    override func awakeFromNib() {
        super.awakeFromNib()
        refreshStyle()
    }

    /// Updates the receiver's colors
    ///
    func refreshStyle() {
        titleLabel.textColor = .simplenoteTextColor
        actionButton.setTitleColor(.simplenoteInteractiveTextColor, for: .normal)
    }
}
