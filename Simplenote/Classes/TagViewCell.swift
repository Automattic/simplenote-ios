import UIKit

// MARK: - TagViewCell
//
class TagViewCell: RoundedView {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.axis = .horizontal
        stackView.spacing = Constants.stackViewSpacing
        return stackView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(for: .subheadline, weight: .medium)
        return label
    }()

    private let deleteButton: UIButton = {
        let button = RoundedCrossButton()
        button.style = .tagPill
        button.isUserInteractionEnabled = false
        button.imageEdgeInsets = Constants.deleteButtonImageInsets

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: Constants.deleteButtonSideSize),
            button.heightAnchor.constraint(equalToConstant: Constants.deleteButtonSideSize)
        ])
        return button
    }()

    /// Tag name
    ///
    let tagName: String

    /// Is delete button visible?
    ///
    var isEditing: Bool {
        get {
            return !deleteButton.isHidden
        }

        set {
            deleteButton.isHidden = !newValue
        }
    }

    /// Callback is invoked when cell switches to editing mode
    ///
    var onEditingBegin: (() -> Void)?

    /// Calback is invoked when user taps on delete button
    ///
    var onDelete: (() -> Void)?

    /// Init with tag name
    ///
    init(tagName: String) {
        self.tagName = tagName
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}


// MARK: - Private
//
private extension TagViewCell {

    func configure() {
        deleteButton.isHidden = true
        setupViewHierarchy()
        refreshStyle()
        setupLabels()
        setupGestureRecognizer()
    }

    func setupViewHierarchy() {
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(deleteButton)

        addFillingSubview(stackView, edgeInsets: Constants.margins, target: .bounds)
    }

    func setupLabels() {
        titleLabel.text = tagName
    }

    func setupGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGestureRecognizer)
    }

    func refreshStyle() {
        backgroundColor = .simplenoteTagPillBackgroundColor
        titleLabel.textColor = .simplenoteTagPillTextColor
    }

    @objc
    func handleTap(_ gestureRecognizer: UIGestureRecognizer) {
        if isEditing {
            let point = gestureRecognizer.location(in: deleteButton)
            if deleteButton.bounds.insetBy(dx: -10, dy: -10).contains(point) {
                onDelete?()
                return
            }
        }

        isEditing = !isEditing
        if isEditing {
            onEditingBegin?()
        }
    }
}


// MARK: - Constants
//
private struct Constants {
    static let margins = UIEdgeInsets(top: 7, left: 12, bottom: 7, right: 12)
    static let stackViewSpacing: CGFloat = 8

    static let deleteButtonImageInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    static let deleteButtonSideSize: CGFloat = 18
}
