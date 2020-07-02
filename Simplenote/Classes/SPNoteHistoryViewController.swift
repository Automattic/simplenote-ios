import UIKit

class SPNoteHistoryViewController: UIViewController {
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var errorMessageLabel: UILabel!
    @IBOutlet private weak var slider: SPSnappingSlider!
    @IBOutlet private weak var restoreButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    private let controller: SPNoteHistoryController
    private var items: [SPNoteHistoryController.Presentable] = []

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

        listenForSliderValueChanges()

        controller.observer = { [weak self] state in
            self?.update(with: state)
        }
        controller.onViewLoad()

        trackScreen()
    }
}

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

    func update(with state: SPNoteHistoryController.State) {
        switch state {
        case .loading:
            setMainContentVisible(false)
            setActivityIndicatorVisible(true)
            setErrorMessageVisible(false)

        case .results(let items):
            setMainContentVisible(true)
            setActivityIndicatorVisible(false)
            setErrorMessageVisible(false)

            self.items = items

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
        let item = items[index]

        dateLabel.text = item.date
        restoreButton.isEnabled = item.isRestorable
        styleRestoreButton()

        controller.selectVersion(atIndex: index)
    }
}

private extension SPNoteHistoryViewController {
    func listenForSliderValueChanges() {
        slider.onValueChange = { [weak self] value in
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

private extension SPNoteHistoryViewController {
    @IBAction func handleTapOnCloseButton() {
        controller.handleTapOnCloseButton()
    }

    @IBAction func handleTapOnRestoreButton() {
        trackRestore()
        controller.handleTapOnRestoreButton()
    }
}

private extension SPNoteHistoryViewController {
    func trackScreen() {
        SPTracker.trackEditorVersionsAccessed()
    }

    func trackRestore() {
        SPTracker.trackEditorNoteRestored()
    }
}
