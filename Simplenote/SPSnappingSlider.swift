import UIKit

@IBDesignable
final class SPSnappingSlider: UISlider {

    @IBInspectable
    var step: Float = 1.0 {
        didSet {
            handleValueChange()
        }
    }

    var onValueChange: ((Float) -> Void)?
    private(set) var snappedValue: Float = 0.0 {
        didSet {
            if oldValue != snappedValue {
                feedbackGenerator?.selectionChanged()
                onValueChange?(snappedValue)
            }
        }
    }

    private var feedbackGenerator: UISelectionFeedbackGenerator?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
}

private extension SPSnappingSlider {
    func configure() {
        addTarget(self, action: #selector(handleValueChange), for: .valueChanged)
        handleValueChange()

        configureImpactGenerator()
    }

    func configureImpactGenerator() {
        feedbackGenerator = UISelectionFeedbackGenerator()
        feedbackGenerator?.prepare()
    }

    @objc
    func handleValueChange() {
        let value = round(self.value / step) * step
        setValue(value, animated: false)
        snappedValue = value
    }
}
