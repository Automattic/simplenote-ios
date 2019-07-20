import Foundation


// MARK: - SPTextInputViewDelegate
//
@objc
protocol SPTextInputViewDelegate : NSObjectProtocol {

    @objc optional
    func textInputDidBeginEditing(_ textInput: SPTextInputView)

    @objc optional
    func textInputDidEndEditing(_ textInput: SPTextInputView)

    @objc optional
    func textInputDidChange(_ textInput: SPTextInputView)

    @objc optional
    func textInputShouldReturn(_ textInput: SPTextInputView) -> Bool

    @objc optional
    func textInput(_ textInput: SPTextInputView, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
}


// MARK: - SPTextInputView
//
@IBDesignable
class SPTextInputView: UIView {

    /// Internal TextField
    ///
    private let textField = SPTextField()

    /// TextField's Autocapitalization Type
    ///
    @IBInspectable var autocapitalizationType: UITextAutocapitalizationType {
        get {
            return textField.autocapitalizationType
        }
        set {
            textField.autocapitalizationType = newValue
        }
    }

    /// TextField's Autocorrection Type
    ///
    @IBInspectable var autocorrectionType: UITextAutocorrectionType {
        get {
            return textField.autocorrectionType
        }
        set {
            textField.autocorrectionType = newValue
        }
    }

    /// Outer Border Color: Enabled State
    ///
    @IBInspectable var borderColorEnabled: UIColor? = Defaults.borderColorEnabled {
        didSet {
            refreshBorderStyle()
        }
    }

    /// Outer Border Color: Disabled State
    ///
    @IBInspectable var borderColorDisabled: UIColor? = Defaults.borderColorDisabled {
        didSet {
            refreshBorderStyle()
        }
    }

    /// Outer Border Radius
    ///
    @IBInspectable var borderCornerRadius: CGFloat = Defaults.cornerRadius {
        didSet {
            refreshBorderStyle()
        }
    }

    /// Outer Border Width
    ///
    @IBInspectable var borderWidth: CGFloat = Defaults.borderWidth {
        didSet {
            refreshBorderStyle()
        }
    }

    /// Indicates if the input text should be obfuscated
    ///
    @IBInspectable var isSecureTextEntry: Bool {
        get {
            return textField.isSecureTextEntry
        }
        set {
            textField.isSecureTextEntry = newValue
        }
    }

    /// TextField's Keyboard Type
    ///
    @IBInspectable var keyboardType: UIKeyboardType {
        get {
            return textField.keyboardType
        }
        set {
            textField.keyboardType = newValue
        }
    }

    /// TextField's Placeholder Color
    ///
    @IBInspectable var placeholderColor: UIColor? {
        get {
            return textField.placeholdTextColor
        }
        set {
            textField.placeholdTextColor = newValue
        }
    }

    /// TextField's Return Key Type
    ///
    @IBInspectable var returnKeyType: UIReturnKeyType {
        get {
            return textField.returnKeyType
        }
        set {
            textField.returnKeyType = newValue
        }
    }

    /// TextField's Right View
    ///
    var rightView: UIView? {
        get {
            return textField.rightView
        }
        set {
            textField.rightView = newValue
        }
    }

    /// TextField's Right View Insets
    ///
    @IBInspectable var rightViewInsets: UIEdgeInsets {
        get {
            return textField.rightViewInsets
        }
        set {
            textField.rightViewInsets = newValue
        }
    }

    /// TextField's Right View Visibility Mode
    ///
    @IBInspectable var rightViewMode: UITextField.ViewMode {
        get {
            return textField.rightViewMode
        }
        set {
            textField.rightViewMode = newValue
        }
    }

    /// TextField's Text
    ///
    @IBInspectable var text: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
        }
    }

    /// TextField's Text Color
    ///
    @IBInspectable var textColor: UIColor? {
        get {
            return textField.textColor
        }
        set {
            textField.textColor = newValue
        }
    }

    /// TextField Placeholder
    ///
    @IBInspectable var placeholder: String? {
        get {
            return textField.placeholder
        }
        set {
            textField.placeholder = newValue
        }
    }

    /// Delegate Wrapper
    ///
    weak var delegate: SPTextInputViewDelegate?


    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupLayout()
        refreshBorderStyle()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
        setupLayout()
        refreshBorderStyle()
    }


    // MARK: - Public Methods

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
}


// MARK: - Private
//
private extension SPTextInputView {

    func setupSubviews() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.placeholdTextColor = Defaults.placeholderColor
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        addSubview(textField)
    }

    func setupLayout() {
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Defaults.insets.left),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Defaults.insets.right),
            textField.topAnchor.constraint(equalTo: topAnchor, constant: Defaults.insets.top),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Defaults.insets.bottom),
            ])
    }

    func refreshBorderStyle() {
        layer.borderColor = textField.isFirstResponder ? borderColorEnabled?.cgColor : borderColorDisabled?.cgColor
        layer.cornerRadius = borderCornerRadius
        layer.borderWidth = borderWidth
    }
}


// MARK: - Relaying editingChanged Events
//
extension SPTextInputView {

    @objc func textFieldDidChange(_ textField: UITextField) {
        delegate?.textInputDidChange?(self)
    }
}


// MARK: - UITextFieldDelegate
//
extension SPTextInputView: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        refreshBorderStyle()
        delegate?.textInputDidBeginEditing?(self)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.textInputDidBeginEditing?(self)
        refreshBorderStyle()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return delegate?.textInputShouldReturn?(self) ?? true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return delegate?.textInput?(self, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }
}


// MARK: - Default Settings
//
private enum Defaults {
    static let cornerRadius         = CGFloat(4)
    static let borderWidth          = CGFloat(1)
    static let insets               = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
    static let borderColorEnabled   = UIColor.simplenotePalePurple()
    static let borderColorDisabled  = UIColor.simplenoteLightPink()
    static let placeholderColor     = UIColor.simplenoteSlateGrey()
}
