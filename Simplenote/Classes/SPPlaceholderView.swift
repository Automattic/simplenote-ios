import Foundation
import UIKit


// MARK: - SPPlaceholderView
//
@objcMembers
class SPPlaceholderView: UIView {

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
}


// MARK: - Constants
//
private enum Constants {
    static let imageViewAlpha = CGFloat(0.5)
    static let numberOfLines = 0
    static let stackViewSpacing = CGFloat(25)
}
