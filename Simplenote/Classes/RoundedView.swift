import UIKit

// MARK: - RoundedView
//
class RoundedView: UIView {
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
private extension RoundedView {
    func configure() {
        layer.masksToBounds = true
        updateCornerRadius()
    }

    func updateCornerRadius() {
        layer.cornerRadius = min(frame.height, frame.width) / 2
    }
}
