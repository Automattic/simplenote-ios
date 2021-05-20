import UIKit

protocol NoticeInteractionDelegate: AnyObject {
    func noticePressBegan()
    func noticePressEnded()
    func actionWasTapped()
}

class NoticeView: UIView {

    // MARK: Properties
    //
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var noticeLabel: UILabel!
    @IBOutlet private weak var noticeButton: UIButton!
    private let blurView = SPBlurEffectView(effect: .simplenoteBlurEffect)

    var message: String? {
        get {
            noticeLabel.text
        }
        set {
            noticeLabel.text = newValue
        }
    }
    var handler: (() -> Void)?
    var actionTitle: String? {
        get {
            noticeButton.title(for: .normal)
        }
        set {
            noticeButton.setTitle(newValue, for: .normal)
            noticeButton.isHidden = newValue == nil
        }
    }

    weak var delegate: NoticeInteractionDelegate?


    // MARK: Initialization
    //
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    // MARK: View Layout
    //
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        setupViewStyles()
        setupGestureRecognizers()
        configureAccessibilityIfNeeded()

        layoutIfNeeded()
    }

    private func setupGestureRecognizers() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(viewWasLongPressed(_:)))
        addGestureRecognizer(longPressGesture)
    }

    private func setupViewStyles() {
        backgroundColor = .clear

        blurView.layer.cornerRadius = Constants.cornerRadius
        blurView.clipsToBounds = true
        blurView.tintColor = .simplenoteNoticeViewBackgroundColor
        blurView.backgroundColor = .clear
        addFillingSubview(blurView)
        sendSubviewToBack(blurView)

        backgroundView.backgroundColor = .simplenoteNoticeViewBackgroundColor
        backgroundView.layer.cornerRadius = Constants.cornerRadius
        backgroundView.alpha = 0.5

        noticeLabel.textColor = .simplenoteTextColor
        noticeButton.setTitleColor(.simplenoteTintColor, for: .normal)
        noticeButton.setTitleColor(.simplenoteCardDismissButtonHighlightedBackgroundColor, for: .highlighted)
        noticeButton.isHidden = true
        noticeButton.titleLabel?.font = UIFont.preferredFont(for: .subheadline, weight: .semibold)
        noticeButton.titleLabel?.adjustsFontForContentSizeCategory = true

    }

    private func configureAccessibilityIfNeeded() {
        switch traitCollection.preferredContentSizeCategory {
        case .accessibilityLarge, .accessibilityExtraLarge, .accessibilityExtraExtraLarge, .accessibilityExtraExtraExtraLarge:
            stackView.axis = .vertical
        default:
            return
        }
    }

    // MARK: Action
    //
    @IBAction func noticeButtonWasTapped(_ sender: Any) {
        delegate?.actionWasTapped()
        handler?()
    }
}

extension NoticeView {

    // MARK: Gesture Recognizers
    //
    @objc
    private func viewWasLongPressed(_ gesture: UIGestureRecognizer) {
        switch gesture.state {
        case .began:
            longPressBegan()
        case .ended:
            longPressEnded()
        default:
            return
        }
    }

    private func longPressBegan() {
        delegate?.noticePressBegan()
    }

    private func longPressEnded() {
        delegate?.noticePressEnded()
    }
}

private struct Constants {
    static let cornerRadius = CGFloat(25)
    static let nibName = "NoticeView"
}
