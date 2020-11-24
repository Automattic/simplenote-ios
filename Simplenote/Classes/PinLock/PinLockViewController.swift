import UIKit

// MARK: - PinLockViewController
//
class PinLockViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBOutlet private var keypadButtons: [UIButton] = [] {
        didSet {
            for button in keypadButtons {
                button.setBackgroundImage(UIColor.simplenoteLockScreenButtonColor.dynamicImageRepresentation(), for: .normal)
                button.setBackgroundImage(UIColor.simplenoteLockScreenHighlightedButtonColor.dynamicImageRepresentation(), for: .highlighted)
                button.addTarget(self, action: #selector(handleTapOnKeypadButton(_:)), for: .touchUpInside)
            }
        }
    }

    @IBOutlet private var cancelButton: UIButton! {
        didSet {
            cancelButton.setTitleColor(.white, for: .normal)
            updateCancelButton()
        }
    }

    @IBOutlet private var progressView: PinLockProgressView! {
        didSet {
            progressView.length = Constants.pinLength
        }
    }

    private var inputValues: [Int] = [] {
        didSet {
            progressView.progress = inputValues.count
            updateCancelButton()
        }
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

// MARK: - Private
//
private extension PinLockViewController {
    func setup() {
        view.backgroundColor = .simplenoteLockScreenBackgroudColor
    }

    func updateCancelButton() {
        cancelButton.setTitle(inputValues.isEmpty ? Localization.cancelButton : Localization.deleteButton,
                              for: .normal)
    }
}

// MARK: - Buttons
//
private extension PinLockViewController {
    @objc
    func handleTapOnKeypadButton(_ button: UIButton) {
        guard let index = keypadButtons.firstIndex(of: button),
              inputValues.count < Constants.pinLength else {
            return
        }

        inputValues.append(index)

    }

    @IBAction
    private func handleTapOnCancelButton() {
        guard !inputValues.isEmpty else {
            return
        }

        inputValues.removeLast()
    }
}

// MARK: - Localization
//
private enum Localization {
    static let deleteButton = NSLocalizedString("Delete", comment: "PinLock screen \"delete\" button")
    static let cancelButton = NSLocalizedString("Cancel", comment: "PinLock screen \"cancel\" button")
}

// MARK: - Constants
//
private enum Constants {
    static let pinLength: Int = 4
}
