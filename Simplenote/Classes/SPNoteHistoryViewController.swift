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

        styleDateLabel()
        styleSlider()
        styleRestoreButton()

        [dateLabel, slider, restoreButton].forEach {
            $0?.alpha = 0.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.activityIndicator.stopAnimating()
            [self.dateLabel, self.slider, self.restoreButton].forEach {
                $0?.alpha = 1.0
            }
        }
    }
}

private extension SPNoteHistoryViewController {
    func styleDateLabel() {
        dateLabel.font = .preferredFont(forTextStyle: .headline)
        dateLabel.textColor = .simplenoteNoteHeadlineColor
    }

    func styleSlider() {
        let color = UIColor.simplenoteGray50Color.withAlphaComponent(0.2)
        slider.minimumTrackTintColor = color
        slider.maximumTrackTintColor = color
    }

    func styleRestoreButton() {
        restoreButton.backgroundColor = .simplenoteBlue50Color // for disabled state .simplenoteDisabledButtonBackgroundColor
    }
}

private extension SPNoteHistoryViewController {
    @IBAction private func handleTapOnCloseButton() {
        eventHandler?(.close)
    }
}
