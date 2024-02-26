import Foundation
import UIKit

// MARK: - SPSortBar
//
class SPSortBar: UIView {

    /// Background Blur
    ///
    private let blurView = SPBlurEffectView.navigationBarBlurView()

    /// Divider: Top separator
    ///
    @IBOutlet private(set) var dividerView: UIView!

    /// Divider: We're aiming at a 1px divider, regardless of the screen scale
    ///
    @IBOutlet private var dividerHeightConstraint: NSLayoutConstraint!

    /// Container: Encapsulates every control!
    ///
    @IBOutlet private var containerView: UIView!

    /// Title: Sort By
    ///
    @IBOutlet private var titleLabel: UILabel!

    /// Description: Active Sort Mode
    ///
    @IBOutlet private var descriptionLabel: UILabel!

    /// Wraps up the Description Label Text
    ///
    var descriptionText: String? {
        get {
            descriptionLabel.text
        }
        set {
            descriptionLabel.text = newValue
        }
    }

    /// Closure to be executed whenever the Sort Mode Button is pressed
    ///
    var onSortModePress: (() -> Void)?

    // MARK: - Lifecycle

    deinit {
        stopListeningToNotifications()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        startListeningToNotifications()

        setupDividerView()
        setupBackgroundView()
        setupBlurEffect()
        setupTextLabels()
        setupSubviews()

        refreshStyle()
    }
}

// MARK: - Private Methods
//
private extension SPSortBar {

    func setupDividerView() {
        dividerHeightConstraint.constant = UIScreen.main.pointToPixelRatio
    }

    func setupBackgroundView() {
        containerView.backgroundColor = .clear
    }

    func setupBlurEffect() {
        blurView.tintColorClosure = {
            .simplenoteSortBarBackgroundColor
        }
    }

    func setupTextLabels() {
        titleLabel.text = NSLocalizedString("Sort by:", comment: "Sort By Title")
        titleLabel.font = .systemFont(ofSize: 12.0)
        descriptionLabel.font = .systemFont(ofSize: 12.0)
    }

    func setupSubviews() {
        insertSubview(blurView, at: .zero)

        blurView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func refreshStyle() {
        dividerView.backgroundColor = .simplenoteDividerColor
        titleLabel.textColor = .simplenoteTextColor
        descriptionLabel.textColor = .simplenoteInteractiveTextColor
    }
}

// MARK: - Notifications
//
private extension SPSortBar {

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

// MARK: - Action Handlers
//
private extension SPSortBar {

    @IBAction func sortModeWasPressed() {
        onSortModePress?()
    }
}
