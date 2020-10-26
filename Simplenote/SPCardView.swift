import UIKit

// MARK: - SPCardView wraps content view in a view with rounded corners and a shadow
//
final class SPCardView: UIView {
    private let containerView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    deinit {
        stopListeningToNotifications()
    }

    /// Add content view
    /// - Parameters:
    ///     - view: content view (will be decorated with rounded corners and a shadow)
    ///
    func addContentView(_ view: UIView) {
        containerView.addFillingSubview(view)
    }
}

// MARK: - Private
//
private extension SPCardView {
    func configure() {
        setupShadowView()
        setupContainerView()
        refreshStyle()
        startListeningToNotifications()
    }

    func setupShadowView() {
        let shadowView = SPShadowView(cornerRadius: Constants.cornerRadius,
                                      roundedCorners: [.topLeft, .topRight])
        addFillingSubview(shadowView)
    }

    func setupContainerView() {
        addFillingSubview(containerView)

        containerView.layer.cornerRadius = Constants.cornerRadius
        containerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        containerView.layer.masksToBounds = true
    }

    func refreshStyle() {
        containerView.backgroundColor = UIColor.simplenoteCardBackgroundColor
    }
}

// MARK: - Notifications
//
private extension SPCardView {
    func startListeningToNotifications() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(themeDidChange), name: .SPSimplenoteThemeChanged, object: nil)
    }

    func stopListeningToNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func themeDidChange() {
        refreshStyle()
    }
}

// MARK: - Constants
//
private struct Constants {
    static let cornerRadius: CGFloat = 10.0
}
