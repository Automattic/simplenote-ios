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
    private var topConstraint: NSLayoutConstraint!

    @IBOutlet
    private var widthConstraint: NSLayoutConstraint!

    @objc
    var appliesTopInset: Bool = false {
        didSet {
            topConstraint.constant = appliesTopInset ? Metrics.defaultTopInset : .zero
        }
    }

    var onPress: (() -> Void)?

    var preferredWidth: CGFloat? {
        didSet {
            guard let preferredWidth else {
                return
            }

            widthConstraint.constant = preferredWidth
        }
    }

    // MARK: - Overridden Methods

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundView.layer.cornerRadius = 8
        backgroundView.backgroundColor = .simplenoteBlue50Color

        titleLabel.text = NSLocalizedString("Become a Simplenote Sustainer", comment: "Sustainer Title")
        detailsLabel.text = NSLocalizedString("Support your favorite notes app to help unlock future features", comment: "Sustainer Legend")

        titleLabel.textColor = .white
        detailsLabel.textColor = .white
    }


    // MARK: - Tap Events

    @IBAction
    func sustainerWasPresssed() {
        onPress?()
    }
}


// MARK: - Metrics
//
private enum Metrics {
    static let defaultTopInset: CGFloat = 19
}
