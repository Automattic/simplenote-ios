import Foundation
import UIKit


// MARK: - SPTagHeaderView
//
@objc @objcMembers
class SPTagHeaderView: UIView {

    /// Left TitleLabel
    ///
    @IBOutlet private(set) var titleLabel: UILabel!

    /// Right ActionButton
    ///
    @IBOutlet private(set) var actionButton: UIButton!


    // MARK: - Overriden Methods

    override func awakeFromNib() {
        super.awakeFromNib()
        refreshStyle()
    }


    /// Updates the receiver's colors
    ///
    func refreshStyle() {
        titleLabel.textColor = .color(name: .textColor)
        actionButton.setTitleColor(.color(name: .simplenoteMidBlue), for: .normal)
    }
}
