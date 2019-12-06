import Foundation
import UIKit

// TODO: Remove
//static CGFloat SPRatingPromptViewWidthPhone             = 320.0f;
//static CGFloat SPRatingPromptViewWidthPad               = 400.0f;
//static CGFloat SPRatingPromptViewHeight                 = 105.0f;
//
//static CGFloat SPRatingPromptLabelPaddingY              = 5.0;
//static CGFloat SPRatingPromptButtonPaddingX             = 5.0f;


// MARK: - SPRatingsPromptDelegate
//
@objc
protocol SPRatingsPromptDelegate: class {
    func simplenoteWasLiked()
    func simplenoteWasDisliked()
    func displayReviewInterface()
    func displayFeedbackInterface()
    func dismissRatingsView()
}


// MARK: - SPRatingsPromptView
//
class SPRatingsPromptView: UIView {

    /// Title
    ///
    @IBOutlet private var messageLabel: UILabel!

    /// Button: Left Action
    ///
    @IBOutlet private var leftButton: UIButton!

    /// Button: Right Action
    ///
    @IBOutlet private var rightButton: UIButton!

    /// Ratings State
    ///
    private var state = State.initial {
        didSet {
            refreshStrigs()
        }
    }

    /// Prompt's Delegate
    ///
    @objc
    weak var delegate: SPRatingsPromptDelegate?


    // MARK: - Lifecycle

    deinit {
        stopListeningToNotifications()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        startListeningToNotifications()
        refreshStyle()
        refreshStrigs()
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

    func refreshStrigs() {
        messageLabel.text = state.title
        leftButton.setTitle(state.leftTitle, for: .normal)
        rightButton.setTitle(state.rightTitle, for: .normal)
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

    @objc func themeDidChange() {
        refreshStyle()
        setNeedsDisplay()
    }
}

// MARK: - Notifications
//
private extension SPRatingsPromptView {

    @IBAction
    func leftActionWasPressed() {
        switch state {
        case .initial:
            delegate?.simplenoteWasLiked()
            state = .liked
        case .liked:
            delegate?.displayReviewInterface()
        case .disliked:
            delegate?.displayFeedbackInterface()
        }
    }

    @IBAction
    func rightActionWasPressed() {
        switch state {
        case .initial:
            delegate?.simplenoteWasDisliked()
            state = .disliked
        case .liked, .disliked:
            delegate?.dismissRatingsView()
        }
    }
}


// MARK: - Constants
//
private struct Settings {
    static let buttonBorderWidth = CGFloat(1)
    static let buttonCornerRAdius = CGFloat(4)
}


// MARK: - Ratings State
//
private enum State {
    case initial
    case liked
    case disliked
}


private extension State {

    var title: String {
        switch self {
        case .initial:
            return NSLocalizedString("What do you think about Simplenote?", comment: "")
        case .liked:
            return NSLocalizedString("Great! Mind leaving a review to tell us what you like?", comment: "")
        case .disliked:
            return NSLocalizedString("Could you tell us how we could improve?", comment: "")
        }
    }

    var leftTitle: String {
        switch self {
        case .initial:
            return NSLocalizedString("I Like It", comment: "")
        case .liked:
            return NSLocalizedString("Leave a Review", comment: "")
        case .disliked:
            return NSLocalizedString("Send Feedback", comment: "")
        }
    }

    var rightTitle: String {
        switch self {
        case .initial:
            return NSLocalizedString("Could Be Better", comment: "")
        case .liked, .disliked:
            return NSLocalizedString("No Thanks", comment: "")
        }
    }
}
