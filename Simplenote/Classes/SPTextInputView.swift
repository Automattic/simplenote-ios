import Foundation


// MARK: - SPTextInputView
//
class SPTextInputView: UIView {

    /// Default Border Radius
    ///
    private let defaultCornerRadius = CGFloat(4)

    /// Default Border Width
    ///
    private let defaultBorderWidth = CGFloat(1)

    /// Default TextView Insets
    ///
    private let defaultInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)

    /// Input TextView
    ///
    let textField = UITextField()

    /// Outer Border (Corner) Radius
    ///
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }

    /// Outer Border Width
    ///
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    /// Outer Border Color
    ///
    var borderColor: CGColor? {
        get {
            return layer.borderColor
        }
        set {
            layer.borderColor = newValue
        }
    }


    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupBorder()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
        setupBorder()
    }
}


// MARK: - Private
//
private extension SPTextInputView {

    func setupSubviews() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textField)

        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: defaultInsets.left),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: defaultInsets.right),
            textField.topAnchor.constraint(equalTo: topAnchor, constant: defaultInsets.top),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: defaultInsets.bottom),
            ])
    }

    func setupBorder() {
        cornerRadius = defaultCornerRadius
        borderWidth = defaultBorderWidth
        borderColor = UIColor.gray.cgColor
    }
}
