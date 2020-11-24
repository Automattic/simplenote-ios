import UIKit

class PinLockViewController: UIViewController {
    @IBOutlet private var keypadButtons: [UIButton] = [] {
        didSet {
            for button in keypadButtons {
                button.setBackgroundImage(UIColor.simplenoteLockScreenButtonColor.dynamicImageRepresentation(), for: .normal)
                button.setBackgroundImage(UIColor.simplenoteLockScreenHighlightedButtonColor.dynamicImageRepresentation(), for: .highlighted)
            }
        }
    }
    @IBOutlet private var cancelButton: UIButton! {
        didSet {
            cancelButton.setTitle(Localization.cancelButton, for: .normal)
            cancelButton.setTitleColor(.white, for: .normal)
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

        view.backgroundColor = .simplenoteLockScreenBackgroudColor
    }
}

private enum Localization {
    static let cancelButton = NSLocalizedString("Cancel", comment: "PinLock screen cancel button")
}
