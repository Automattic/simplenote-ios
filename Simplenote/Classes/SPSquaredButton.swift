import Foundation


// MARK: - SPSquaredButton: Simple convenience UIButton subclass, with a default corner radius
//
@IBDesignable
class SPSquaredButton: UIButton {

    /// Default Radius
    ///
    private let defaultCornerRadius = CGFloat(8)

    /// Outer Border Radius
    ///
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupStyle()
    }
}


// MARK: - Private Methods
//
private extension SPSquaredButton {

    func setupStyle() {
        cornerRadius = defaultCornerRadius
    }
}
