import Foundation
import UIKit


// MARK: - SPNoteTableViewCell
//
@objcMembers
class SPNoteTableViewCell: UITableViewCell {

    /// Master View
    ///
    @IBOutlet private var containerView: UIView!

    /// Accessory StackView
    ///
    @IBOutlet private var accessoryStackView: UIStackView!

    /// Accessory StackView's Top Constraint
    ///
    @IBOutlet private var accessoryStackViewCenterConstraintY: NSLayoutConstraint!

    /// Acccesory LeftImage's Height
    ///
    @IBOutlet private var accessoryLeftImageViewHeightConstraint: NSLayoutConstraint!

    /// Acccesory RightImage's Height
    ///
    @IBOutlet private var accessoryRightImageViewHeightConstraint: NSLayoutConstraint!

    /// Note's Left Accessory ImageView
    ///
    @IBOutlet private var accessoryLeftImageView: UIImageView!

    /// Note's Right Accessory ImageView
    ///
    @IBOutlet private var accessoryRightImageView: UIImageView!

    /// TextView to act as Note's Text container
    ///
    private let previewTextView = SPTextView()

    /// Left Accessory Image
    ///
    var accessoryLeftImage: UIImage? {
        get {
            return accessoryLeftImageView.image
        }
        set {
            accessoryLeftImageView.image = newValue
            accessoryLeftImageView.isHidden = newValue == nil
            refreshTextViewInsets()
        }
    }

    /// Left AccessoryImage's Tint
    ///
    var accessoryLeftTintColor: UIColor? {
        get {
            return accessoryLeftImageView.tintColor
        }
        set {
            accessoryLeftImageView.tintColor = newValue
        }
    }

    /// Right AccessoryImage
    ///
    var accessoryRightImage: UIImage? {
        get {
            return accessoryRightImageView.image
        }
        set {
            accessoryRightImageView.image = newValue
            accessoryRightImageView.isHidden = newValue == nil
            refreshTextViewInsets()
        }
    }

    /// Right AccessoryImage's Tint
    ///
    var accessoryRightTintColor: UIColor? {
        get {
            return accessoryRightImageView.tintColor
        }
        set {
            accessoryRightImageView.tintColor = newValue
        }
    }

    /// Number of Maximum Preview lines to be rendered
    ///
    var numberOfPreviewLines: Int {
        get {
            return previewTextView.textContainer.maximumNumberOfLines
        }
        set {
            previewTextView.textContainer.maximumNumberOfLines = newValue
        }
    }

    /// Note's Text
    ///
    var previewText: NSAttributedString? {
        get {
            return previewTextView.attributedText
        }
        set {
            previewTextView.attributedText = newValue
        }
    }

    /// Returns the Preview's Fragment Padding
    ///
    var previewLineFragmentPadding: CGFloat {
        return previewTextView.textContainer.lineFragmentPadding
    }

    /// Deinitializer
    ///
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// Designated Initializer
    ///
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        startListeningToNotifications()
    }


    // MARK: - Overridden Methods

    override func awakeFromNib() {
        super.awakeFromNib()
        setupTextView()
        setupLayout()
        refreshStyle()
        refreshConstraints()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        refreshStyle()
        refreshConstraints()
    }

    /// Highlights the partial matches with the specified color.
    ///
    func highlightSubstrings(matching keywords: String, color: UIColor) {
        previewTextView.highlightSubstrings(matching: keywords, color: color)
    }
}


// MARK: - Private Methods: Initialization
//
private extension SPNoteTableViewCell {

    /// Setup: TextView
    ///
    func setupTextView() {
        previewTextView.isScrollEnabled = false
        previewTextView.isUserInteractionEnabled = false
        previewTextView.isEditable = false
        previewTextView.isAccessibilityElement = false
        previewTextView.backgroundColor = .clear
        previewTextView.textContainerInset = .zero

        let container = previewTextView.textContainer
        container.maximumNumberOfLines = Options.shared.numberOfPreviewLines
        container.lineFragmentPadding = .zero
        container.lineBreakMode = .byWordWrapping
    }

    /// Autolayout Init
    ///
    func setupLayout() {
        previewTextView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(previewTextView)

        NSLayoutConstraint.activate([
            previewTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            previewTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            previewTextView.topAnchor.constraint(equalTo: containerView.topAnchor),
            previewTextView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
    }
}


// MARK: - Notifications
//
private extension SPNoteTableViewCell {

    /// Wires the (related) notifications to their handlers
    ///
    func startListeningToNotifications() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(contentSizeCatoryWasUpdated), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }

    /// Handles the UIContentSizeCategory.didChange Notification
    ///
    @objc
    func contentSizeCatoryWasUpdated() {
        refreshConstraints()
    }
}


// MARK: - Private Methods: Skinning
//
private extension SPNoteTableViewCell {

    /// Refreshes the current Style current style
    ///
    func refreshStyle() {
        backgroundColor = Style.backgroundColor

        let selectedView = UIView(frame: bounds)
        selectedView.backgroundColor = Style.selectionColor
        selectedBackgroundView = selectedView

        previewTextView.interactiveTextStorage.tokens = [
            SPHeadlineTokenName: [
                .font: Style.headlineFont,
                .foregroundColor: Style.headlineColor
            ],
            SPDefaultTokenName: [
                .font: Style.previewFont,
                .foregroundColor: Style.previewColor
            ]
        ]
    }

    /// Accessory's StackView should be aligned against the PreviewTextView's first line center
    ///
    func refreshConstraints() {
        let lineHeight = Style.headlineFont.lineHeight
        let centerY = ceil(lineHeight * 0.5)
        let dimension = ceil(lineHeight * Style.accessoryImageSizeRatio)
        let cappedDimension = max(min(dimension, Style.accessoryImageMaximumSize), Style.accessoryImageMinimumSize)

        accessoryStackViewCenterConstraintY.constant = centerY
        accessoryLeftImageViewHeightConstraint.constant = cappedDimension
        accessoryRightImageViewHeightConstraint.constant = cappedDimension
    }

    /// Applies the TextView Insets, based on the accessoryStack's Width
    ///
    func refreshTextViewInsets() {
        accessoryStackView.layoutIfNeeded()
        previewTextView.textContainerInset.right = Style.previewInsets.right + accessoryStackView.frame.width
    }
}


// MARK: - Cell Styles
//
private enum Style {

    /// Preview's Text Insets
    ///
    static let previewInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)

    /// Accessory's Ratio (measured against Line Size)
    ///
    static let accessoryImageSizeRatio = CGFloat(0.75)

    /// Accessory's Minimum Size
    ///
    static let accessoryImageMinimumSize = CGFloat(16)

    /// Accessory's Maximum Size
    ///
    static let accessoryImageMaximumSize = CGFloat(24)

    /// Returns the Cell's Background Color
    ///
    static var backgroundColor: UIColor {
        .color(name: .backgroundColor)!
    }

    /// Headline Color: To be applied over the first preview line
    ///
    static var headlineColor: UIColor {
        .color(name: .noteHeadlineFontColor)!
    }

    /// Headline Font: To be applied over the first preview line
    ///
    static var headlineFont: UIFont {
        .preferredFont(forTextStyle: .headline)
    }

    /// Preview Color: To be applied over  the preview's body (everything minus the first line)
    ///
    static var previewColor: UIColor {
        .color(name: .noteBodyFontPreviewColor)!
    }

    /// Preview Font: To be applied over  the preview's body (everything minus the first line)
    ///
    static var previewFont: UIFont {
        .preferredFont(forTextStyle: .subheadline)
    }

    /// Color to be applied over the cell upon selection
    ///
    static var selectionColor: UIColor {
        .color(name: .lightBlueColor)!
    }
}
