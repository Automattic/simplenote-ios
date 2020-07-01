import UIKit

class SPNoteHistoryViewController: UIViewController {
    enum Event {
        case close
    }

    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var slider: UISlider!
    @IBOutlet private weak var restoreButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    var eventHandler: ((Event) -> Void)?

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        [dateLabel, slider, restoreButton].forEach {
            $0?.alpha = 0.0
        }
    }
}

private extension SPNoteHistoryViewController {
    func customizeDateLabel() {
        dateLabel.font = .preferredFont(forTextStyle: .headline)
        dateLabel.textColor = .simplenoteNoteHeadlineColor
    }

    func customizeSlider() {
        slider.minimumTrackTintColor = slider.maximumTrackTintColor
    }

    func customizeRestoreButton() {

    }
}

private extension SPNoteHistoryViewController {
    @IBAction private func handleTapOnCloseButton() {
        eventHandler?(.close)
    }
}
