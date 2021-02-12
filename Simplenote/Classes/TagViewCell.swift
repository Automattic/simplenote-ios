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
    var isDeleteButtonVisible: Bool {
        get {
            return !deleteButton.isHidden
        }

        set {
            deleteButton.isHidden = !newValue
        }
    }

    /// Callback is invoked when user taps on the cell
    ///
    var onTap: (() -> Void)?

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
        setupAccessibility()
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
        if isDeleteButtonVisible {
            let point = gestureRecognizer.location(in: deleteButton)
            let insetBounds = deleteButton.bounds.insetBy(dx: Constants.deleteButtonHitAreaInset,
                                                          dy: Constants.deleteButtonHitAreaInset)
            if insetBounds.contains(point) {
                onDelete?()
                return
            }
        }

        onTap?()
    }
}


// MARK: - Accessibility
//
extension TagViewCell {
    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityLabel = tagName

        let deleteAction = UIAccessibilityCustomAction(name: Localization.removeTagHint, target: self, selector: #selector(accessibilityRemoveTag))
        accessibilityCustomActions = [deleteAction]
    }

    @objc
    private func accessibilityRemoveTag() -> Bool {
        onDelete?()
        return true
    }
}


// MARK: - Constants
//
private struct Constants {
    static let margins = UIEdgeInsets(top: 7, left: 12, bottom: 7, right: 12)
    static let stackViewSpacing: CGFloat = 8

    static let deleteButtonImageInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    static let deleteButtonSideSize: CGFloat = 18

    static let deleteButtonHitAreaInset: CGFloat = -10
}


// MARK: - Localization
//
private struct Localization {
    static let removeTagHint = NSLocalizedString("tag-delete-accessibility-hint", comment: "Remove a tag from the current note")
}
