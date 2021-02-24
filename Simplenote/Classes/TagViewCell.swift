import UIKit

// MARK: - TagViewCell
//
class TagViewCell: RoundedView {

    private var stackViewConstraints: EdgeConstraints!

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
        label.textAlignment = .center
        return label
    }()

    private let deleteButton: UIButton = {
        let button = RoundedCrossButton()
        button.style = .tagPill
        button.isUserInteractionEnabled = false
        button.contentMode = .scaleAspectFit

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
            updateStackViewConstraints()
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
        setupMinConstraints()
        refreshStyle()
        setupLabels()
        setupGestureRecognizer()
        setupAccessibility()
    }

    func setupViewHierarchy() {
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(deleteButton)

        stackViewConstraints = addFillingSubview(stackView)
        updateStackViewConstraints()
    }

    func setupMinConstraints() {
        let minHeight = Constants.marginsWhenDeleteIsVisible.top + Constants.deleteButtonSideSize + Constants.marginsWhenDeleteIsVisible.bottom
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight),
            widthAnchor.constraint(greaterThanOrEqualTo: heightAnchor, multiplier: Constants.widthConstraintMultiplier)
        ])
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

    func updateStackViewConstraints() {
        let edgeInsets = isDeleteButtonVisible ? Constants.marginsWhenDeleteIsVisible : Constants.margins
        stackViewConstraints.update(with: edgeInsets)
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
    static let margins = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)
    static let marginsWhenDeleteIsVisible = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 5)

    static let stackViewSpacing: CGFloat = 8

    static let widthConstraintMultiplier: CGFloat = 1.3

    static let deleteButtonSideSize: CGFloat = 20
    static let deleteButtonHitAreaInset: CGFloat = -10
}


// MARK: - Localization
//
private struct Localization {
    static let removeTagHint = NSLocalizedString("tag-delete-accessibility-hint", comment: "Remove a tag from the current note")
}
