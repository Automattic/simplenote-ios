import UIKit

// MARK: - RoundedButton
//
class RoundedButton: UIButton {
    override var bounds: CGRect {
        didSet {
            guard bounds.size != oldValue.size else {
                return
            }

            updateCornerRadius()
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
}

// MARK: - Private
//
private extension RoundedButton {
    func configure() {
        layer.masksToBounds = true
        updateCornerRadius()
    }

    func updateCornerRadius() {
        layer.cornerRadius = min(frame.height, frame.width) / 2
    }
}
