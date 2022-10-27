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

    var isActiveSustainer = false {
        didSet {
            refreshInterface()
        }
    }

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
        refreshInterface()
    }


    // MARK: - Actions

    @IBAction
    func sustainerWasPresssed() {
        onPress?()
    }
}


// MARK: - Private API(s)
//
private extension SustainerView {

    func refreshInterface() {
        let style = isActiveSustainer ? Style.sustainer : Style.notSubscriber

        titleLabel.text = style.title
        detailsLabel.text = style.details
        titleLabel.textColor = style.textColor
        detailsLabel.textColor = style.textColor
        backgroundView.backgroundColor = style.backgroundColor
        backgroundView.layer.cornerRadius = Metrics.defaultCornerRadius
    }
}


// MARK: - Style
//
private struct Style {
    let title: String
    let details: String
    let textColor: UIColor
    let backgroundColor: UIColor
}


private extension Style {
    static var sustainer: Style {
        Style(title: NSLocalizedString("You are a Simplenote Sustainer", comment: "Current Sustainer Title"),
              details: NSLocalizedString("Thank you for your continued support", comment: "Current Sustainer Details"),
              textColor: .white,
              backgroundColor: .simplenoteSustainerViewBackgroundColor)
    }

    static var notSubscriber: Style {
        Style(title: NSLocalizedString("Become a Simplenote Sustainer", comment: "Become a Sustainer Title"),
              details: NSLocalizedString("Support your favorite notes app to help unlock future features", comment: "Become a Sustainer Details"),
              textColor: .white,
              backgroundColor: .simplenoteBlue50Color)
    }
}


// MARK: - Metrics
//
private enum Metrics {
    static let defaultTopInset: CGFloat = 19
    static let defaultCornerRadius: CGFloat = 8
}
