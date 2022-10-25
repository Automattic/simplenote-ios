import Foundation
import UIKit


// MARK: - SustainerView
//
class SustainerView: UIView {

    @IBOutlet
    private var backgroundView: UIView!

    @IBOutlet
    private var titleLabel: UILabel!

    @IBOutlet
    private var detailsLabel: UILabel!

    @IBOutlet
    private var widthConstraint: NSLayoutConstraint!

    public var preferredWidth: CGFloat? {
        didSet {
            guard let preferredWidth else {
                return
            }

            widthConstraint.constant = preferredWidth
        }
    }


    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundView.layer.cornerRadius = 8
        backgroundView.backgroundColor = .simplenoteBlue50Color

        titleLabel.text = NSLocalizedString("Become a Simplenote Sustainer", comment: "Sustainer Title")
        detailsLabel.text = NSLocalizedString("Support your favorite notes app to help unlock future features", comment: "Sustainer Legend")

        titleLabel.textColor = .white
        detailsLabel.textColor = .white
    }
}
