import UIKit

// MARK: - SPShadowView
//
// SPShadowView draws outside shadow, while everyting inside is kept transparent
//
final class SPShadowView: UIView {
    private let cornerRadius: CGFloat
    private let roundedCorners: UIRectCorner
    private let maskLayer: CAShapeLayer = CAShapeLayer()

    override var bounds: CGRect {
        didSet {
            updatePath()
        }
    }

    /// Designated Initializer
    ///
    ///  - cornerRadius: The radius of each corner oval
    ///  - roundedCorners: A bitmask value that identifies the corners that you want rounded
    ///
    init(cornerRadius: CGFloat, roundedCorners: UIRectCorner) {
        self.cornerRadius = cornerRadius
        self.roundedCorners = roundedCorners

        super.init(frame: .zero)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = Constants.shadowOffset
        layer.shadowOpacity = Constants.shadowOpacity
        layer.shadowRadius = Constants.shadowRadius
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
        static let shadowOpacity: Float = 0.1
        static let shadowRadius: CGFloat = 4.0
        static let shadowOffset = CGSize(width: 0, height: -2)
    }
}
