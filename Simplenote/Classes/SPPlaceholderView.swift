import Foundation
import UIKit


// MARK: - SPPlaceholderView
//
@objcMembers
class SPPlaceholderView: UIView {

    /// DisplayMode: Defines the way in which the Placeholder behaves
    ///
    enum DisplayMode {
        case picture
        case pictureAndText
        case text
    }

    /// Placeholder's Display Mode
    ///
    var displayMode: DisplayMode = .pictureAndText {
        didSet {
            displayModeWasChanged()
        }
    }


    /// Placeholder Image
    ///
    private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.alpha = Constants.imageViewAlpha
        imageView.contentMode = .center
        return imageView
    }()

    /// Placeholder TextLabel
    ///
    private(set) lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = Constants.numberOfLines
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()

    /// Internal StackView
    ///
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, textLabel])
        stackView.axis = .vertical
        stackView.spacing = Constants.stackViewSpacing
        return stackView
    }()


    // MARK: - Initializers

    init() {
        super.init(frame: .zero)
        configureSubviews()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureSubviews()
        configureLayout()
    }
}


// MARK: - Private Methods
//
private extension SPPlaceholderView {

    func configureSubviews() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
    }

    func configureLayout() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    func displayModeWasChanged() {
        imageView.isHidden = !displayMode.displaysPicture
        textLabel.isHidden = !displayMode.displaysText
        textLabel.font = displayMode.textFont
    }
}


// MARK: - Constants
//
private enum Constants {
    static let imageViewAlpha = CGFloat(0.5)
    static let numberOfLines = 0
    static let stackViewSpacing = CGFloat(25)
}


// MARK: - SPPlaceholderView.DisplayMode Properties
//
extension SPPlaceholderView.DisplayMode {

    var displaysPicture: Bool {
        guard self == .text else {
            return true
        }

        return false
    }

    var displaysText: Bool {
        guard self == .picture else {
            return true
        }

        return false
    }

    var textFont: UIFont {
        guard self == .text else {
            return .preferredFont(forTextStyle: .body)
        }

        return .preferredFont(forTextStyle: .title3)
    }
}
