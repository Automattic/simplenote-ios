import UIKit

// MARK: - SPShadowView
//
// SPShadowView draws outside shadow, while everyting inside is kept transparent
//
@IBDesignable
final class SPShadowView: UIView {
    private let maskLayer = CAShapeLayer()

    /// Corner Radius
    ///
    @IBInspectable
    var cornerRadius: CGFloat = .zero {
        didSet {
            updatePath()
        }
    }

    /// Defines the Shadow Path's rounded corners
    ///
    var roundedCorners: UIRectCorner = .allCorners {
        didSet {
            updatePath()
        }
    }

    /// Shadow color
    ///
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            layer.shadowColor.map {
                UIColor(cgColor: $0)
            }
        }
        set {
            layer.shadowColor = newValue?.cgColor
        }
    }

    /// Shadow Offset
    ///
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }

    /// Shadow Opacity
    ///
    @IBInspectable
    var shadowOpacity: CGFloat {
        get {
            CGFloat(layer.shadowOpacity)
        }
        set {
            layer.shadowOpacity = Float(newValue)
        }
    }

    /// Shadow Radius
    ///
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }

    override var bounds: CGRect {
        didSet {
            updatePath()
        }
    }

    /// Designated Initializer
    ///
    ///  - Parameters:
    ///     - cornerRadius: The radius of each corner oval
    ///     - roundedCorners: A bitmask value that identifies the corners that you want rounded
    ///
    init(cornerRadius: CGFloat, roundedCorners: UIRectCorner) {
        self.cornerRadius = cornerRadius
        self.roundedCorners = roundedCorners

        super.init(frame: .zero)
        configure()
    }

    /// NSCoder support!
    ///
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
}

// MARK: - Private Methods
//
private extension SPShadowView {

    /// Initial configuration of the view
    ///
    func configure() {
        backgroundColor = .clear

        configureShadow()
        configureMask()

        updatePath()
    }

    /// Configuration of the shadow
    ///
    func configureShadow() {
        shadowColor = Constants.shadowColor
        shadowOffset = Constants.shadowOffset
        shadowOpacity = Constants.shadowOpacity
        shadowRadius = Constants.shadowRadius
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }

    /// Configuration of the mask
    ///
    func configureMask() {
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.fillRule = .evenOdd
        layer.mask = maskLayer
    }

    /// Updates paths of the shadow and the mask to reflect the view bounds
    ///
    func updatePath() {
        let roundedPath = UIBezierPath(roundedRect: bounds,
                                       byRoundingCorners: roundedCorners,
                                       cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))

        layer.shadowPath = roundedPath.cgPath

        // Path including outside shadow
        let maskPath = UIBezierPath(rect: bounds.insetBy(dx: -Constants.shadowRadius * 2 - abs(layer.shadowOffset.width),
                                                         dy: -Constants.shadowRadius * 2 - abs(layer.shadowOffset.height)))
        maskPath.append(roundedPath)
        maskPath.usesEvenOddFillRule = true
        maskLayer.path = maskPath.cgPath
    }
}

// MARK: - Constants
//
private extension SPShadowView {
    struct Constants {
        static let shadowColor = UIColor.black
        static let shadowOpacity: CGFloat = 0.1
        static let shadowRadius: CGFloat = 4.0
        static let shadowOffset = CGSize(width: 0, height: -2)
    }
}
