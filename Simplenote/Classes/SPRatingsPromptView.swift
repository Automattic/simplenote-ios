import Foundation
import UIKit

// MARK: - SPRatingsPromptDelegate
//
@objc
protocol SPRatingsPromptDelegate: AnyObject {
    func simplenoteWasLiked()
    func simplenoteWasDisliked()
    func displayReviewUI()
    func displayFeedbackUI()
    func dismissRatingsUI()
}

// MARK: - SPRatingsPromptView
//
class SPRatingsPromptView: UIView {

    /// Title
    ///
    @IBOutlet private var messageLabel: UILabel!

    /// Buttons Container
    ///
    @IBOutlet private var buttonsStackView: UIStackView!

    /// Leading Padding
    ///
    @IBOutlet private var leadingLayoutConstraint: NSLayoutConstraint!

    /// Trailing Padding
    ///
    @IBOutlet private var trailingLayoutConstraint: NSLayoutConstraint!

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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        refreshButtonsStackViewAxis()
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

    func refreshButtonsStackViewAxis() {
        guard let superviewWidth = superview?.frame.width else {
            return
        }

        buttonsStackView.axis = .horizontal

        let newButtonsWidth = buttonsStackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).width
        let newFullWidth = leadingLayoutConstraint.constant + newButtonsWidth + trailingLayoutConstraint.constant

        if newFullWidth > superviewWidth {
            buttonsStackView.axis = .vertical
        }
    }
}

// MARK: - Notifications
//
private extension SPRatingsPromptView {

    func startListeningToNotifications() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(themeDidChange), name: .SPSimplenoteThemeChanged, object: nil)
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
            delegate?.displayReviewUI()
        case .disliked:
            delegate?.displayFeedbackUI()
        }
    }

    @IBAction
    func rightActionWasPressed() {
        switch state {
        case .initial:
            delegate?.simplenoteWasDisliked()
            state = .disliked
        case .liked, .disliked:
            delegate?.dismissRatingsUI()
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
            return NSLocalizedString("What do you think about Simplenote?", comment: "Rating view initial title")
        case .liked:
            return NSLocalizedString("Great! Mind leaving a review to tell us what you like?", comment: "Rating view liked title")
        case .disliked:
            return NSLocalizedString("Could you tell us how we could improve?", comment: "Rating view disliked title")
        }
    }

    var leftTitle: String {
        switch self {
        case .initial:
            return NSLocalizedString("I like it", comment: "Rating view - initial - liked button")
        case .liked:
            return NSLocalizedString("Leave a review", comment: "Rating view - liked - leave review button")
        case .disliked:
            return NSLocalizedString("Send feedback", comment: "Rating view - disliked - send feedback button")
        }
    }

    var rightTitle: String {
        switch self {
        case .initial:
            return NSLocalizedString("Could be better", comment: "Rating view - initial - could be better button")
        case .liked, .disliked:
            return NSLocalizedString("No thanks", comment: "Rating view - liked or disliked - no thanks button")
        }
    }
}
