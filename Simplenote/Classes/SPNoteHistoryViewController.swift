import UIKit

// MARK: - SPNoteHistoryViewController: Shows history for a note
//
class SPNoteHistoryViewController: UIViewController {
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var errorMessageLabel: UILabel!
    @IBOutlet private weak var slider: SPSnappingSlider!
    @IBOutlet private weak var restoreButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    private let controller: SPNoteHistoryController
    private var versions: [SPHistoryVersion] = []

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

    override func viewDidLoad() {
        super.viewDidLoad()

        styleDateLabel()
        styleErrorMessageLabel()
        styleSlider()
        styleRestoreButton()
        styleActivityIndicator()

        listenForSliderValueChanges()

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
    func styleDateLabel() {
        dateLabel.textColor = .simplenoteNoteHeadlineColor
    }

    func styleErrorMessageLabel() {
        errorMessageLabel.textColor = .simplenoteTextColor
    }

    func styleSlider() {
        let color = UIColor.simplenoteGray50Color.withAlphaComponent(0.2)
        slider.minimumTrackTintColor = color
        slider.maximumTrackTintColor = color
    }

    func styleRestoreButton() {
        restoreButton.backgroundColor = restoreButton.isEnabled ? .simplenoteBlue50Color : .simplenoteDisabledButtonBackgroundColor
        restoreButton.setTitle(NSLocalizedString("Restore Note", comment: "Restore a note to a previous version"), for: .normal)
    }

    func styleActivityIndicator() {
        if #available(iOS 13.0, *) {
            activityIndicator.style = .medium
        } else {
            activityIndicator.style = .gray
        }
    }

    func update(with state: SPNoteHistoryController.State) {
        switch state {
        case .loading:
            setMainContentVisible(false)
            setActivityIndicatorVisible(true)
            setErrorMessageVisible(false)

        case .results(let versions):
            setMainContentVisible(true)
            setActivityIndicatorVisible(false)
            setErrorMessageVisible(false)

            self.versions = versions

            configureSlider()

        case .error(let text):
            setMainContentVisible(false)
            setActivityIndicatorVisible(false)
            setErrorMessageVisible(true)

            errorMessageLabel.text = text
        }
    }

    func update(withSliderValue value: Float) {
        let index = Int(value)
        let version = versions[index]

        dateLabel.text = controller.note.dateString(version.modificationDate, brief: false)
        restoreButton.isEnabled = version.version != controller.note.versionInt
        styleRestoreButton()

        controller.select(version: version)
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
        slider.maximumValue = Float(max(versions.count - 1, 0))
        slider.value = slider.maximumValue
        update(withSliderValue: slider.value)
    }
}

// MARK: - Updating content visibility
//
private extension SPNoteHistoryViewController {
    func setMainContentVisible(_ isVisible: Bool) {
        [dateLabel, slider, restoreButton].forEach {
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
