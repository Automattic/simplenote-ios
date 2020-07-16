import UIKit

// MARK: - SPSnappingSlider - Slider that snaps to certain values
//
@IBDesignable
final class SPSnappingSlider: UISlider {

    /// Step for snapping
    ///
    @IBInspectable
    var step: Float = 1.0 {
        didSet {
            setValue(value, animated: false)
        }
    }

    /// Callback to be executed when snapped value is updated
    ///
    var onSnappedValueChange: ((Float) -> Void)?

    /// Feedback generator is used to notify the user about changes in selection
    ///
    private var feedbackGenerator: UISelectionFeedbackGenerator?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    /// Set and snap a value according to the step
    ///
    override func setValue(_ value: Float, animated: Bool) {
        let oldValue = self.value

        var value = max(value, minimumValue)
        value = min(value, maximumValue)
        value = round(value / step) * step

        super.setValue(value, animated: animated)

        if oldValue != value {
            feedbackGenerator?.selectionChanged()
            onSnappedValueChange?(value)
        }
    }
}

// MARK: - Private Methods
//
private extension SPSnappingSlider {
    func configure() {
        configureFeedbackGenerator()
    }

    func configureFeedbackGenerator() {
        feedbackGenerator = UISelectionFeedbackGenerator()
        feedbackGenerator?.prepare()
    }
}

// MARK: - Accessibility
extension SPSnappingSlider {
    override func accessibilityIncrement() {
        setValue(value + step, animated: true)
    }

    override func accessibilityDecrement() {
        setValue(value - step, animated: true)
    }
}
