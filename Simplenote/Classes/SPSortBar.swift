import Foundation
import UIKit


// MARK: - SPSortBar
//
class SPSortBar: UIView {

    /// Background Blur
    ///
    private let blurView = SPBlurEffectView.navigationBarBlurView()

    /// Container: Encapsulates every control!
    ///
    @IBOutlet private var containerView: UIView!

    /// Sort Order Button!
    ///
    @IBOutlet private var sortOrderButton: UIButton!

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

    /// Closure to be executed whenever the Sort Order [View] (center of the Sort Bar) is pressed
    ///
    var onSortOrderPress: (() -> Void)?


    // MARK: - Initializers

    override func awakeFromNib() {
        super.awakeFromNib()
        setupBackgroundView()
        setupBlurEffect()
        setupTextLabels()
        setupOrderButton()
        setupSubviews()
    }
}


// MARK: - Private Methods
//
private extension SPSortBar {

    func setupBackgroundView() {
        containerView.backgroundColor = .clear
    }

    func setupBlurEffect() {
        blurView.tintColorClosure = {
            .simplenoteNavigationBarBackgroundColor
        }
    }

    func setupTextLabels() {
        titleLabel.text = NSLocalizedString("Sort by:", comment: "Sort By Title")
        titleLabel.font = .preferredFont(for: .caption1, weight: .regular)
        titleLabel.textColor = .simplenoteTextColor

        descriptionLabel.font = .preferredFont(for: .caption1, weight: .medium)
        descriptionLabel.textColor = .simplenoteInteractiveTextColor
    }

    func setupOrderButton() {
        sortOrderButton.imageView?.contentMode = .center
        sortOrderButton.imageView?.tintColor = .simplenoteTintColor
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
}


// MARK: - Action Handlers
//
private extension SPSortBar {

    @IBAction func sortOrderWasPressed() {
        onSortOrderPress?()
    }

    @IBAction func sortModeWasPressed() {
        onSortModePress?()
    }
}
