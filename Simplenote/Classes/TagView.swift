import UIKit

// MARK: - TagViewDelegate
//
protocol TagViewDelegate: class {
    func tagView(_ tagView: TagView, shouldCreateTagWithName name: String) -> Bool
    func tagView(_ tagView: TagView, didCreateTagWithName name: String)
    func tagView(_ tagView: TagView, didRemoveTagWithName name: String)

    func tagViewDidBeginEditing(_ tagView: TagView)
    func tagViewDidChange(_ tagView: TagView)
}


// MARK: - TagView
//
class TagView: UIView {

    private lazy var tagStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()

    private lazy var tagScrollView: UIScrollView = {
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

    /// Delegate
    ///
    weak var tagDelegate: TagViewDelegate?

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
        clearAll()

        for tagName in tagNames {
            tagStackView.addArrangedSubview(cell(for: tagName))
        }
    }

    override func endEditing(_ force: Bool) -> Bool {
        clearEditing()
        return super.endEditing(force)
    }

    func scrollEntryFieldToVisible(animated: Bool) {
        guard !isEditingTag else {
            return
        }

        tagScrollView.scrollRectToVisible(addTagField.frame, animated: animated)
    }
}


// MARK: - Private
//
private extension TagView {
    func configure() {
        setupViewHierarchy()
    }

    func setupViewHierarchy() {
        let stackView = UIStackView(arrangedSubviews: [tagStackView, addTagField])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 16

        tagScrollView.addFillingSubview(stackView, edgeInsets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))

        addFillingSubview(tagScrollView)
    }
}


// MARK: - Cells
//
private extension TagView {
    var tagCells: [TagViewCell] {
        return (tagStackView.arrangedSubviews as? [TagViewCell]) ?? []
    }

    func cell(for tagName: String) -> TagViewCell {
        let cell = TagViewCell(tagName: tagName)
        cell.onEditingBegin = { [weak self] in
            self?.clearEditing(except: tagName)
        }
        cell.onDelete = { [weak self] in
            self?.removeTag(with: tagName)
        }
        return cell
    }

    func clearAll() {
        for view in tagStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
    }
}


// MARK: - Editing
//
private extension TagView {
    var isEditingTag: Bool {
        tagCells.contains(where: { $0.isEditing })
    }

    func clearEditing(except tagName: String? = nil) {
        for cell in tagCells {
            cell.isEditing = cell.tagName == tagName
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
        case .endingWithWhitespace(let text):
            textField.text = text
            processTextInFieldToTag()
            return false
        case .invalid:
            return false
        }
    }

    func processTextInFieldToTag() {
        let tagName = addTagField.text ?? ""

        if !tagName.isEmpty && tagDelegate?.tagView(self, shouldCreateTagWithName: tagName) == true {

            tagStackView.addArrangedSubview(cell(for: tagName))
            tagDelegate?.tagView(self, didCreateTagWithName: tagName)
        }

        addTagField.text = ""
//        updateAutoComplete()
    }

    func removeTag(with tagName: String) {
        guard let cell = tagCells.first(where: { $0.tagName == tagName }) else {
            return
        }

        cell.removeFromSuperview()
        tagDelegate?.tagView(self, didRemoveTagWithName: tagName)
    }
}

// MARK: - UITextFieldDelegate
//
extension TagView: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        clearEditing()
//        updateAutoComplete()

        DispatchQueue.main.async {
            self.tagDelegate?.tagViewDidBeginEditing(self)
            self.scrollEntryFieldToVisible(animated: true)
        }

        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return validateInput(textField, range: range, replacement: string)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        processTextInFieldToTag()
        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        clearEditing()
        processTextInFieldToTag()
    }
}


// MARK: - SPTagEntryFieldDelegate
//
extension TagView: SPTagEntryFieldDelegate {
    func tagEntryFieldDidChange(_ tagTextField: SPTagEntryField!) {
        clearEditing()

        DispatchQueue.main.async {
            self.scrollEntryFieldToVisible(animated: true)
        }

        tagDelegate?.tagViewDidChange(self)
//        updateAutoComplete()
    }
}
