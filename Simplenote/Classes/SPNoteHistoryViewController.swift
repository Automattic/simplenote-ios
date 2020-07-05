import UIKit

// MARK: - SPNoteHistoryViewController: Shows history for a note
//
class SPNoteHistoryViewController: UIViewController {
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var errorMessageLabel: UILabel!
    @IBOutlet private weak var slider: SPSnappingSlider!
    @IBOutlet private weak var restoreButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var dismissButton: UIButton!

    private let controller: SPNoteHistoryController
    private var items: [SPNoteHistoryController.Presentable] = []

    /// Designated initialize
    ///
    /// - Parameters:
    ///     - controller: business logic controller
    ///
    init(controller: SPNoteHistoryController) {
        self.controller = controller
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        stopListeningToNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshStyle()
        configureAccessibility()
        listenForSliderValueChanges()

        startListeningToNotifications()

        controller.observer = { [weak self] state in
            self?.update(with: state)
        }
        controller.onViewLoad()

        trackScreen()
    }
}

// MARK: - Private Methods
//
private extension SPNoteHistoryViewController {
    func refreshStyle() {
        styleDateLabel()
        styleErrorMessageLabel()
        styleSlider()
        styleRestoreButton()
        styleActivityIndicator()
    }

    func styleDateLabel() {
        dateLabel.textColor = .simplenoteNoteHeadlineColor
    }

    func styleErrorMessageLabel() {
        errorMessageLabel.textColor = .simplenoteTextColor
    }

    func styleSlider() {
        let color = UIColor.color(lightColor: UIColor.simplenoteGray50Color.withAlphaComponent(Constants.sliderBackgroundAlphaLight),
                                  darkColor: UIColor.simplenoteGray50Color.withAlphaComponent(Constants.sliderBackgroundAlphaDark))
        slider.minimumTrackTintColor = color
        slider.maximumTrackTintColor = color
    }

    func styleRestoreButton() {
        restoreButton.layer.masksToBounds = true

        restoreButton.setBackgroundImage(UIColor.simplenoteBlue50Color.dynamicImageRepresentation(), for: .normal)
        restoreButton.setBackgroundImage(UIColor.simplenoteDisabledButtonBackgroundColor.dynamicImageRepresentation(), for: .disabled)
        restoreButton.setBackgroundImage(UIColor.simplenoteBlue60Color.dynamicImageRepresentation(), for: .highlighted)

        restoreButton.setTitle(NSLocalizedString("Restore Note", comment: "Restore a note to a previous version"), for: .normal)
    }

    func styleActivityIndicator() {
        if #available(iOS 13.0, *) {
            activityIndicator.style = .medium
        } else {
            activityIndicator.style = SPUserInterface.isDark ? .white : .gray
        }
    }

    func update(with state: SPNoteHistoryController.State) {
        switch state {
        case .loading:
            setMainContentVisible(false)
            setActivityIndicatorVisible(true)
            setErrorMessageVisible(false)

            setAccessibilityFocus(activityIndicator)

        case .results(let items):
            setMainContentVisible(true)
            setActivityIndicatorVisible(false)
            setErrorMessageVisible(false)

            self.items = items

            configureSlider()

            setAccessibilityFocus(slider)

        case .error(let text):
            setMainContentVisible(false)
            setActivityIndicatorVisible(false)
            setErrorMessageVisible(true)

            errorMessageLabel.text = text

            setAccessibilityFocus(errorMessageLabel)
        }
    }

    func update(withSliderValue value: Float) {
        let index = Int(value)
        let item = items[index]

        dateLabel.text = item.date
        restoreButton.isEnabled = item.isRestorable

        updateSliderAccessibilityValue(with: item)

        controller.selectVersion(atIndex: index)
    }
}

// MARK: - Slider
//
private extension SPNoteHistoryViewController {
    func listenForSliderValueChanges() {
        slider.onSnappedValueChange = { [weak self] value in
            self?.update(withSliderValue: value)
        }
    }

    func configureSlider() {
        slider.minimumValue = 0.0
        slider.maximumValue = Float(max(items.count - 1, 0))
        slider.value = slider.maximumValue
        update(withSliderValue: slider.value)
    }
}

// MARK: - Updating content visibility
//
private extension SPNoteHistoryViewController {
    func setMainContentVisible(_ isVisible: Bool) {
        [dateLabel, slider, restoreButton].forEach {
            $0?.alpha = isVisible ? 1.0 : 0.0
        }
    }

    func setActivityIndicatorVisible(_ isVisible: Bool) {
        if isVisible {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

    func setErrorMessageVisible(_ isVisible: Bool) {
        errorMessageLabel.alpha = isVisible ? 1.0 : 0.0
    }
}

// MARK: - Handling button events
//
private extension SPNoteHistoryViewController {
    @IBAction func handleTapOnCloseButton() {
        controller.handleTapOnCloseButton()
    }

    @IBAction func handleTapOnRestoreButton() {
        trackRestore()
        controller.handleTapOnRestoreButton()
    }
}

// MARK: - Notifications
//
private extension SPNoteHistoryViewController {
    func startListeningToNotifications() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(themeDidChange), name: .VSThemeManagerThemeDidChange, object: nil)
    }

    func stopListeningToNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func themeDidChange() {
        refreshStyle()
    }
}

// MARK: - Tracking
//
private extension SPNoteHistoryViewController {
    func trackScreen() {
        SPTracker.trackEditorVersionsAccessed()
    }

    func trackRestore() {
        SPTracker.trackEditorNoteRestored()
    }
}

// MARK: - Accessibility
//
extension SPNoteHistoryViewController {
    override func accessibilityPerformEscape() -> Bool {
        controller.handleTapOnCloseButton()
        return true
    }

    private func setAccessibilityFocus(_ element: UIView) {
        UIAccessibility.post(notification: .layoutChanged, argument: element)
    }

    private func configureAccessibility() {
        dismissButton.accessibilityLabel = NSLocalizedString("note-history-dismiss-button-accessibility-label", comment: "Accessiblity label describing a button used to dismiss a history view of the note")
        slider.accessibilityLabel = NSLocalizedString("note-history-slider-accessibility-label", comment: "Accessiblity label describing a slider used to reset the current note to a previous version")
    }

    private func updateSliderAccessibilityValue(with item: SPNoteHistoryController.Presentable) {
        slider.accessibilityValue = item.date
    }
}

// MARK: - Constants
//
private extension SPNoteHistoryViewController {
    struct Constants {
        static let sliderBackgroundAlphaLight: CGFloat = 0.2
        static let sliderBackgroundAlphaDark: CGFloat = 0.36
    }
}
