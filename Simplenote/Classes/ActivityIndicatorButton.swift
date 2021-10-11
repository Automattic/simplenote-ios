import UIKit

// MARK: - ActivityIndicatorButton
//
class ActivityIndicatorButton: UIButton {

    private lazy var activityIndicator = UIActivityIndicatorView()

    /// In Progress
    ///
    var inProgress: Bool = false {
        didSet {
            if inProgress {
                titleLabel?.alpha = UIKitConstants.alpha0_0
                activityIndicator.startAnimating()
            } else {
                titleLabel?.alpha = UIKitConstants.alpha1_0
                activityIndicator.stopAnimating()
            }

            isEnabled = !inProgress
        }
    }

    /// Activity indicator color
    ///
    var activityIndicatorColor: UIColor? {
        get {
            return activityIndicator.color
        }

        set {
            activityIndicator.color = newValue
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

private extension ActivityIndicatorButton {
    func configure() {
        activityIndicator.hidesWhenStopped = true

        addSubview(activityIndicator)
        pinSubviewToCenter(activityIndicator)

        styleActivityIndicator()
    }

    func styleActivityIndicator() {
        activityIndicator.style = .medium
    }
}
