import UIKit

// MARK: - PinLockProgressView
//
final class PinLockProgressView: UIStackView {

    /// Length of the progress view
    ///
    var length: Int = 0 {
        didSet {
            configure()
        }
    }

    /// Progress is from 0 to `length`
    ///
    var progress: Int = 0 {
        didSet {
            guard oldValue != progress else {
                return
            }

            progress = min(progress, length)
            update()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
}

// MARK: - Private
//
private extension PinLockProgressView {
    func configure() {
        for view in arrangedSubviews {
            removeArrangedSubview(view)
        }

        for _ in 0..<length {
            let button = RoundedButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.isUserInteractionEnabled = false
            button.setBackgroundImage(UIColor.clear.dynamicImageRepresentation(), for: .normal)
            button.setBackgroundImage(UIColor.white.dynamicImageRepresentation(), for: .highlighted)
            button.layer.borderWidth = Constants.buttonBorderWidth
            button.layer.borderColor = UIColor.white.cgColor
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: Constants.buttonSideSize),
                button.heightAnchor.constraint(equalToConstant: Constants.buttonSideSize)
            ])
            addArrangedSubview(button)
        }
    }

    func update() {
        for (i, button) in arrangedSubviews.enumerated() {
            (button as? UIButton)?.isHighlighted = i < progress
        }
    }
}

// MARK: - Constants
//
private enum Constants {
    static let buttonBorderWidth: CGFloat = 1.0
    static let buttonSideSize: CGFloat = 14.0
}
