import UIKit

// MARK: - TagViewDelegate
//
protocol TagViewDelegate: AnyObject {
    func tagView(_ tagView: TagView, wantsToCreateTagWithName name: String)
    func tagView(_ tagView: TagView, wantsToRemoveTagWithName name: String)

    func tagViewDidBeginEditing(_ tagView: TagView)
    func tagViewDidChange(_ tagView: TagView)
}

// MARK: - TagView
//
class TagView: UIView {

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = Constants.tagsStackViewSpacing
        return stackView
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.scrollsToTop = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private lazy var addTagField: SPTagEntryField = {
        let field = SPTagEntryField()
        field.delegate = self
        field.tagDelegate = self
        return field
    }()

    private var autohideDeleteButtonTimer: Timer? {
        didSet {
            oldValue?.invalidate()
        }
    }

    /// Delegate
    ///
    weak var delegate: TagViewDelegate?

    /// Keyboard appearance
    ///
    var keyboardAppearance: UIKeyboardAppearance {
        get {
            return addTagField.keyboardAppearance
        }

        set {
            addTagField.keyboardAppearance = newValue
        }
    }

    var addTagFieldText: String? {
        get {
            addTagField.text
        }

        set {
            addTagField.text = newValue
        }
    }

    var addTagFieldFrameInWindow: CGRect {
        var frame = addTagField.convert(addTagField.bounds, to: self)
        frame.origin.y = 0
        frame.size.height = frame.size.height
        return convert(frame, to: nil)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    /// Setup with a list of tag names
    ///
    func setup(withTagNames tagNames: [String]) {
        removeAllTags()

        for tagName in tagNames {
            add(tag: tagName)
        }
    }

    /// Add a tag with specified name
    ///
    func add(tag tagName: String) {
        stackView.addArrangedSubview(cell(for: tagName))
        updateStackViewVisibility()
    }

    /// Remove a tag with specified name
    ///
    func remove(tag tagName: String) {
        guard let cell = tagCells.first(where: { $0.tagName == tagName }) else {
            return
        }

        cell.removeFromSuperview()
        updateStackViewVisibility()
    }

    override func endEditing(_ force: Bool) -> Bool {
        hideDeleteButton()
        return super.endEditing(force)
    }

    func scrollEntryFieldToVisible(animated: Bool) {
        guard !isShowingDeleteButton else {
            return
        }

        layoutIfNeeded()

        let addTagFieldFrame = addTagField.convert(addTagField.bounds, to: scrollView)
        scrollView.scrollRectToVisible(addTagFieldFrame.insetBy(dx: -Constants.wrappingStackViewMargins.right, dy: 0),
                                       animated: animated)
    }
}

// MARK: - Private
//
private extension TagView {
    func configure() {
        setupViewHierarchy()
    }

    func setupViewHierarchy() {
        setupHiddenCell()

        let wrappingStackView = UIStackView(arrangedSubviews: [stackView, addTagField])
        wrappingStackView.axis = .horizontal
        wrappingStackView.alignment = .center
        wrappingStackView.distribution = .fill
        wrappingStackView.spacing = Constants.wrappingStackViewSpacing

        scrollView.addFillingSubview(wrappingStackView, edgeInsets: Constants.wrappingStackViewMargins)
        wrappingStackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true

        addFillingSubview(scrollView)

        if UIApplication.isRTL {
            scrollView.transform = CGAffineTransform(rotationAngle: .pi)
            wrappingStackView.transform =  CGAffineTransform(rotationAngle: .pi)
        }
    }

    /// Sets up hidden cell to make sure view has correct height even if there are no tags
    ///
    func setupHiddenCell() {
        let hiddenCell = TagViewCell(tagName: "A")
        hiddenCell.translatesAutoresizingMaskIntoConstraints = false
        hiddenCell.isHidden = true
        hiddenCell.isAccessibilityElement = false

        addSubview(hiddenCell)
        NSLayoutConstraint.activate([
            hiddenCell.topAnchor.constraint(equalTo: topAnchor, constant: Constants.hiddenCellVerticalMargin),
            hiddenCell.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.hiddenCellVerticalMargin),
            hiddenCell.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    func updateStackViewVisibility() {
        stackView.isHidden = stackView.arrangedSubviews.isEmpty
    }
}

// MARK: - Cells
//
private extension TagView {
    var tagCells: [TagViewCell] {
        return (stackView.arrangedSubviews as? [TagViewCell]) ?? []
    }

    func cell(for tagName: String) -> TagViewCell {
        let cell = TagViewCell(tagName: tagName)

        cell.onTap = { [weak self, weak cell] in
            guard let self = self, let cell = cell else {
                return
            }
            self.toggleDeleteButton(for: cell)
        }

        cell.onDelete = { [weak self] in
            guard let self = self else {
                return
            }
            self.delegate?.tagView(self, wantsToRemoveTagWithName: tagName)
        }

        return cell
    }

    func removeAllTags() {
        for view in stackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        updateStackViewVisibility()
    }
}

// MARK: - Editing
//
private extension TagView {
    var isShowingDeleteButton: Bool {
        tagCells.contains(where: { $0.isDeleteButtonVisible })
    }

    func toggleDeleteButton(for cell: TagViewCell) {
        let newValue = !cell.isDeleteButtonVisible
        hideDeleteButton()
        cell.isDeleteButtonVisible = newValue

        if newValue {
            autohideDeleteButtonTimer = Timer.scheduledTimer(withTimeInterval: Constants.autohideDeleteButtonTimeout,
                                                             repeats: false,
                                                             block: { [weak self] (_) in
                                                                self?.hideDeleteButton()
                                                             })
        }
    }

    func hideDeleteButton() {
        autohideDeleteButtonTimer = nil

        for cell in tagCells {
            cell.isDeleteButtonVisible = false
        }
    }
}

// MARK: - Tag processing
//
private extension TagView {
    func validateInput(_ textField: UITextField, range: NSRange, replacement: String) -> Bool {
        let text = (textField.text ?? "")
        guard let range = Range(range, in: text) else {
            return true
        }

        let validator = TagTextFieldInputValidator()
        let result = validator.validateInput(originalText: text, range: range, replacement: replacement)
        switch result {
        case .valid:
            return true
        case .endingWithDisallowedCharacter(let text):
            textField.text = text
            processTextInFieldToTag()
            return false
        case .invalid:
            return false
        }
    }

    func processTextInFieldToTag() {
        guard let tagName = addTagField.text, !tagName.isEmpty else {
            return
        }

        delegate?.tagView(self, wantsToCreateTagWithName: tagName)
        addTagField.text = ""

        scrollEntryFieldToVisible(animated: true)
    }
}

// MARK: - UITextFieldDelegate
//
extension TagView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hideDeleteButton()

        delegate?.tagViewDidBeginEditing(self)
        scrollEntryFieldToVisible(animated: true)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return validateInput(textField, range: range, replacement: string)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        processTextInFieldToTag()
        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        hideDeleteButton()
        processTextInFieldToTag()
    }
}

// MARK: - SPTagEntryFieldDelegate
//
extension TagView: SPTagEntryFieldDelegate {
    func tagEntryFieldDidChange(_ tagTextField: SPTagEntryField!) {
        hideDeleteButton()

        DispatchQueue.main.async {
            self.scrollEntryFieldToVisible(animated: true)
        }

        delegate?.tagViewDidChange(self)
    }
}

// MARK: - Constants
//
private struct Constants {
    static let wrappingStackViewSpacing: CGFloat = 16
    static let wrappingStackViewMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

    static let tagsStackViewSpacing: CGFloat = 8

    static let hiddenCellVerticalMargin: CGFloat = 8

    static let autohideDeleteButtonTimeout: TimeInterval = 4.0
}
