import Foundation
import UIKit

// TODO: Remove
//static CGFloat SPRatingPromptViewWidthPhone             = 320.0f;
//static CGFloat SPRatingPromptViewWidthPad               = 400.0f;
//static CGFloat SPRatingPromptViewHeight                 = 105.0f;
//
//static CGFloat SPRatingPromptLabelPaddingY              = 5.0;
//static CGFloat SPRatingPromptButtonPaddingX             = 5.0f;


// MARK: - SPRatingsPromptView
//
class SPRatingsPromptView: UIView {

    /// Title
    ///
    @IBOutlet var messageLabel: UILabel!

    /// Button: Left Action
    ///
    @IBOutlet var leftButton: UIButton!

    /// Button: Right Action
    ///
    @IBOutlet var rightButton: UIButton!


    // MARK: - Lifecycle

    deinit {
        stopListeningToNotifications()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        refreshStyle()
        startListeningToNotifications()
    }
}


// MARK: - Private Methods
//
private extension SPRatingsPromptView {

    func refreshStyle() {
        refreshTitleStyle()
        refreshButtonsStyle()
    }

    func refreshTitleStyle() {
        messageLabel.font = .preferredFont(forTextStyle: .headline)
        messageLabel.textColor = .simplenoteNoteHeadlineColor
    }

    func refreshButtonsStyle() {
        let buttonColor = UIColor.simplenoteTintColor
        let buttonFont = UIFont.preferredFont(forTextStyle: .subheadline)
        let buttons = [leftButton, rightButton].compactMap { $0 }

        for button in buttons {
            button.backgroundColor = .clear
            button.layer.borderWidth = Settings.buttonBorderWidth
            button.layer.cornerRadius = Settings.buttonCornerRAdius
            button.layer.borderColor = buttonColor.cgColor
            button.titleLabel?.font = buttonFont
            button.setTitleColor(buttonColor, for: .normal)
        }
    }
}


// MARK: - Notifications
//
private extension SPRatingsPromptView {

    func startListeningToNotifications() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(themeDidChange), name: .VSThemeManagerThemeDidChange, object: nil)
    }

    func stopListeningToNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func themeDidChange(sender: Notification) {
        refreshStyle()
        setNeedsDisplay()
    }
}


// MARK: - Constants
//
private struct Settings {
    static let buttonBorderWidth = CGFloat(1)
    static let buttonCornerRAdius = CGFloat(4)
}
