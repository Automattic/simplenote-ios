import Foundation


// MARK: - SPTextInputView
//
class SPTextInputView: UIView {

    /// Internal TextField
    ///
    private let textField = SPTextField()

    /// TextField's Autocapitalization Type
    ///
    var autocapitalizationType: UITextAutocapitalizationType {
        get {
            return textField.autocapitalizationType
        }
        set {
            textField.autocapitalizationType = newValue
        }
    }

    /// TextField's Autocorrection Type
    ///
    var autocorrectionType: UITextAutocorrectionType {
        get {
            return textField.autocorrectionType
        }
        set {
            textField.autocorrectionType = newValue
        }
    }

    /// Outer Border Color: Enabled State
    ///
    var borderColorEnabled: UIColor? = Defaults.borderColorEnabled {
        didSet {
            refreshBorderStyle()
        }
    }

    /// Outer Border Color: Disabled State
    ///
    var borderColorDisabled: UIColor? = Defaults.borderColorDisabled {
        didSet {
            refreshBorderStyle()
        }
    }

    /// Outer Border Radius
    ///
    var borderCornerRadius: CGFloat = Defaults.cornerRadius {
        didSet {
            refreshBorderStyle()
        }
    }

    /// Outer Border Width
    ///
    var borderWidth: CGFloat = Defaults.borderWidth {
        didSet {
            refreshBorderStyle()
        }
    }

    /// Indicates if the input text should be obfuscated
    ///
    var isSecureTextEntry: Bool {
        get {
            return textField.isSecureTextEntry
        }
        set {
            textField.isSecureTextEntry = newValue
        }
    }

    /// TextField's Keyboard Type
    ///
    var keyboardType: UIKeyboardType {
        get {
            return textField.keyboardType
        }
        set {
            textField.keyboardType = newValue
        }
    }

    /// TextField's Placeholder Color
    ///
    var placeholderColor: UIColor? {
        get {
            return textField.placeholdTextColor
        }
        set {
            textField.placeholdTextColor = newValue
        }
    }

    /// TextField's Return Key Type
    ///
    var returnKeyType: UIReturnKeyType {
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
    var rightViewInsets: UIEdgeInsets {
        get {
            return textField.rightViewInsets
        }
        set {
            textField.rightViewInsets = newValue
        }
    }

    /// TextField's Right View Visibility Mode
    ///
    var rightViewMode: UITextField.ViewMode {
        get {
            return textField.rightViewMode
        }
        set {
            textField.rightViewMode = newValue
        }
    }

    /// TextField's Text
    ///
    var text: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
        }
    }

    /// TextField's Text Color
    ///
    var textColor: UIColor? {
        get {
            return textField.textColor
        }
        set {
            textField.textColor = newValue
        }
    }

    /// TextField Placeholder
    ///
    var placeholder: String? {
        get {
            return textField.placeholder
        }
        set {
            textField.placeholder = newValue
        }
    }


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


// MARK: - UITextFieldDelegate
//
extension SPTextInputView: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        refreshBorderStyle()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        refreshBorderStyle()
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
