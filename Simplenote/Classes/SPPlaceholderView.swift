import Foundation
import UIKit

// MARK: - SPPlaceholderView
//
@objc
class SPPlaceholderView: UIView {

    /// DisplayMode: Defines the way in which the Placeholder behaves
    ///
    enum DisplayMode {
        case generic
        case pictureAndText(imageName: UIImageName, text: String)
        case text(text: String, actionText: String, actionHandler: () -> Void)
    }

    /// Placeholder's Display Mode
    ///
    var displayMode: DisplayMode = .generic {
        didSet {
            displayModeWasChanged()
        }
    }

    /// Placeholder Image
    ///
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.alpha = Constants.imageViewAlpha
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    /// Placeholder TextLabel
    ///
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = Constants.numberOfLines
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()

    /// Placeholder ActionLabel
    ///
    private lazy var actionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = Constants.numberOfLines
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()

    /// Internal StackView
    ///
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, textLabel, actionLabel])
        stackView.axis = .vertical
        return stackView
    }()

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)
        configureSubviews()
        setupGestureRecognizer()
        startListeningToNotifications()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureSubviews()
        setupGestureRecognizer()
        startListeningToNotifications()
    }

    deinit {
        stopListeningToNotifications()
    }
}

// MARK: - Private Methods
//
private extension SPPlaceholderView {

    func configureSubviews() {
        imageView.heightAnchor.constraint(equalToConstant: Constants.imageViewHeight).isActive = true

        addFillingSubview(stackView)
        refreshStyle()
    }

    func refreshStyle() {
        imageView.tintColor = .simplenotePlaceholderImageColor
        actionLabel.textColor = .simplenoteBlue50Color
        textLabel.textColor = .simplenotePlaceholderTextColor

        switch displayMode {
        case .text:
            textLabel.font = .preferredFont(forTextStyle: .title3)
            stackView.spacing = Constants.stackViewCondensedSpacing

        default:
            textLabel.font = .preferredFont(forTextStyle: .body)
            stackView.spacing = Constants.stackViewDefaultSpacing
        }
    }

    func displayModeWasChanged() {
        switch displayMode {
        case .generic:
            imageView.image = .image(name: .simplenoteLogo)
            textLabel.text = nil
            actionLabel.text = nil

        case .pictureAndText(let imageName, let text):
            imageView.image = .image(name: imageName)
            textLabel.text = text
            actionLabel.text = nil

        case .text(let text, let action, _):
            imageView.image = nil
            textLabel.text = text
            actionLabel.text = action
        }

        imageView.isHidden = imageView.image == nil
        textLabel.isHidden = textLabel.text == nil
        actionLabel.isHidden = actionLabel.text == nil

        refreshStyle()
    }

    func setupGestureRecognizer() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }

    @objc
    func handleTap() {
        guard case DisplayMode.text(_, _, let actionHandler) = displayMode else {
            return
        }

        actionHandler()
    }
}

// MARK: - Theme
//
private extension  SPPlaceholderView {
    func startListeningToNotifications() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(themeDidChange), name: .SPSimplenoteThemeChanged, object: nil)
    }

    func stopListeningToNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    func themeDidChange() {
        refreshStyle()
    }
}

// MARK: - Constants
//
private enum Constants {
    static let imageViewAlpha = CGFloat(0.5)
    static let imageViewHeight = CGFloat(72)
    static let numberOfLines = 0
    static let stackViewDefaultSpacing = CGFloat(25)
    static let stackViewCondensedSpacing = CGFloat(5)
}
