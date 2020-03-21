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

    /// Message label
    @IBOutlet private(set) var messageLabel: UILabel! {
        didSet {
            messageLabel.text = NSLocalizedString(
                "Once you add tags to your notes, your tags will appear here.",
                comment: "Message displayed when no tags exist"
            )
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
        messageLabel.textColor = .simplenoteTextColor
    }
}
