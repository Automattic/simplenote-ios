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

    private var transitioningManager: UIViewControllerTransitioningDelegate?

    private let controller: SPNoteHistoryController

    /// Designated initializer
    ///
    /// - Parameters:
    ///     - controller: business logic controller
    ///
    init(controller: SPNoteHistoryController) {
        self.controller = controller
        super.init(nibName: nil, bundle: nil)
    }

    /// Convenience initializer
    ///
    /// - Parameters:
    ///     - note: Note
    ///     - delegate: History delegate
    ///
    convenience init(note: Note, delegate: SPNoteHistoryControllerDelegate) {
        let controller = SPNoteHistoryController(note: note)
        controller.delegate = delegate

        self.init(controller: controller)
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
        configureSlider()
        configureAccessibility()

        startListeningToNotifications()
        startListeningForControllerChanges()
        startListeningForSliderValueChanges()

        controller.onViewLoad()

        trackScreen()
    }
}

// MARK: - Styling
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
        slider.minimumTrackTintColor = .simplenoteSliderTrackColor
        slider.maximumTrackTintColor = .simplenoteSliderTrackColor
    }

    func styleRestoreButton() {
        restoreButton.layer.masksToBounds = true

        restoreButton.setBackgroundImage(UIColor.simplenoteBlue50Color.dynamicImageRepresentation(), for: .normal)
        restoreButton.setBackgroundImage(UIColor.simplenoteDisabledButtonBackgroundColor.dynamicImageRepresentation(), for: .disabled)
        restoreButton.setBackgroundImage(UIColor.simplenoteBlue60Color.dynamicImageRepresentation(), for: .highlighted)

        restoreButton.setTitle(Localization.restoreButtonTitle, for: .normal)
    }

    func styleActivityIndicator() {
        activityIndicator.style = .medium
    }
}

// MARK: - Updating UI
//
private extension SPNoteHistoryViewController {
    func update(with state: SPNoteHistoryController.State) {
        switch state {
        case .version(let versionNumber, let date, let isRestorable):
            switchToMainContent(isLoading: false)

            dateLabel.text = date
            restoreButton.isEnabled = isRestorable

            updateSlider(withVersionNumber: versionNumber,
                         accessibilityValue: date)

        case .loadingVersion(let versionNumber):
            switchToMainContent(isLoading: true)

            restoreButton.isEnabled = false

            updateSlider(withVersionNumber: versionNumber,
                         accessibilityValue: Localization.activityIndicatorAccessibilityLabel)

        case .error(let text):
            switchToErrorMessage()

            errorMessageLabel.text = text

            setAccessibilityFocus(errorMessageLabel)
        }
    }

    func updateSlider(withVersionNumber versionNumber: Int, accessibilityValue: String?) {
        slider.value = Float(versionNumber)
        updateSliderAccessibilityValue(accessibilityValue)
        setAccessibilityFocus(slider)
    }
}

// MARK: - Slider
//
private extension SPNoteHistoryViewController {
    func startListeningForSliderValueChanges() {
        slider.onSnappedValueChange = { [weak self] value in
            self?.controller.select(versionNumber: Int(value))
        }
    }

    func configureSlider() {
        let range = controller.versionRange
        slider.minimumValue = Float(range.lowerBound)
        slider.maximumValue = Float(range.upperBound)
    }
}

// MARK: - Updating content visibility
//
private extension SPNoteHistoryViewController {
    func switchToMainContent(isLoading: Bool) {
        setSliderAndActionButtonVisible(true)
        setDateVisible(!isLoading)
        setActivityIndicatorVisible(isLoading)

        setErrorMessageVisible(false)
    }

    func switchToErrorMessage() {
        setDateVisible(false)
        setSliderAndActionButtonVisible(false)
        setActivityIndicatorVisible(false)

        setErrorMessageVisible(true)
    }

    func setDateVisible(_ isVisible: Bool) {
        // We manipulate alpha to prevent content jumping because of re-layouting
        dateLabel.alpha = isVisible ? UIKitConstants.alpha1_0 : UIKitConstants.alpha0_0
    }

    func setSliderAndActionButtonVisible(_ isVisible: Bool) {
        [slider, restoreButton].forEach {
            $0?.alpha = isVisible ? UIKitConstants.alpha1_0 : UIKitConstants.alpha0_0
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
        errorMessageLabel.isHidden = !isVisible
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

// MARK: - Controller
//
private extension SPNoteHistoryViewController {
    func startListeningForControllerChanges() {
        controller.observer = { [weak self] state in
            self?.update(with: state)
        }
    }
}

// MARK: - Theme Notifications
//
private extension SPNoteHistoryViewController {
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
        guard !element.accessibilityElementIsFocused() else {
            return
        }
        UIAccessibility.post(notification: .layoutChanged, argument: element)
    }

    private func configureAccessibility() {
        dismissButton.accessibilityLabel = Localization.dismissAccessibilityLabel
        slider.accessibilityLabel = Localization.sliderAccessibilityLabel
        activityIndicator.accessibilityLabel = Localization.activityIndicatorAccessibilityLabel
    }

    private func updateSliderAccessibilityValue(_ value: String?) {
        slider.accessibilityValue = value
    }
}

// MARK: - Presentation
//
extension SPNoteHistoryViewController {

    /// Configure view controller to be presented as a card
    ///
    func configureToPresentAsCard(presentationDelegate: SPCardPresentationControllerDelegate) {
        let transitioningManager = SPCardTransitioningManager()
        transitioningManager.presentationDelegate = presentationDelegate
        self.transitioningManager = transitioningManager

        transitioningDelegate = transitioningManager
        modalPresentationStyle = .custom
    }
}

// MARK: - SPCardConfigurable
//
extension SPNoteHistoryViewController: SPCardConfigurable {
    func shouldBeginSwipeToDismiss(from location: CGPoint) -> Bool {
        let locationInSlider = slider.convert(location, from: view)
        // Add an extra padding to the thumb to prevent dismissing from the area around the thumb as well
        let thumbRect = slider.thumbRect.insetBy(dx: -Constants.sliderThumbPadding,
                                                 dy: -Constants.sliderThumbPadding)
        return !thumbRect.contains(locationInSlider)
    }
}

// MARK: - Constants
//
private struct Constants {
    static let sliderThumbPadding: CGFloat = 15.0
}

private struct Localization {
    static let restoreButtonTitle = NSLocalizedString("Restore Note", comment: "Restore a note to a previous version")
    static let dismissAccessibilityLabel = NSLocalizedString("Dismiss History", comment: "Accessibility label describing a button used to dismiss a history view of the note")
    static let sliderAccessibilityLabel = NSLocalizedString("Select a Version", comment: "Accessibility label describing a slider used to reset the current note to a previous version")
    static let activityIndicatorAccessibilityLabel = NSLocalizedString("Fetching Version", comment: "Accessibility hint used when previous versions of a note are being fetched")
}
