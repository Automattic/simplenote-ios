import Foundation
import UIKit


// MARK: - SPNoteTableViewCell
//
@objcMembers
class SPNoteTableViewCell: UITableViewCell {

    /// Master View
    ///
    @IBOutlet private var titleTextView: UITextView!

    /// Accessory StackView
    ///
    @IBOutlet private var bodyTextView: UITextView!

    /// Accessory StackView's Top Constraint
    ///
    @IBOutlet private var accessoryStackView: UIStackView!

    /// Note's Left Accessory ImageView
    ///
    @IBOutlet private var accessoryLeftImageView: UIImageView!

    /// Note's Right Accessory ImageView
    ///
    @IBOutlet private var accessoryRightImageView: UIImageView!

    /// Acccesory LeftImage's Height
    ///
    @IBOutlet private var accessoryLeftImageViewHeightConstraint: NSLayoutConstraint!

    /// Acccesory RightImage's Height
    ///
    @IBOutlet private var accessoryRightImageViewHeightConstraint: NSLayoutConstraint!

    /// Left Accessory Image
    ///
    var accessoryLeftImage: UIImage? {
        get {
            accessoryLeftImageView.image
        }
        set {
            accessoryLeftImageView.image = newValue
            refreshAccessoriesVisibility()
        }
    }

    /// Left AccessoryImage's Tint
    ///
    var accessoryLeftTintColor: UIColor? {
        get {
            accessoryLeftImageView.tintColor
        }
        set {
            accessoryLeftImageView.tintColor = newValue
        }
    }

    /// Right AccessoryImage
    ///
    var accessoryRightImage: UIImage? {
        get {
            accessoryRightImageView.image
        }
        set {
            accessoryRightImageView.image = newValue
            refreshAccessoriesVisibility()
        }
    }

    /// Right AccessoryImage's Tint
    ///
    var accessoryRightTintColor: UIColor? {
        get {
            accessoryRightImageView.tintColor
        }
        set {
            accessoryRightImageView.tintColor = newValue
        }
    }

    /// Note's Title
    ///
    var titleText: String? {
        get {
            titleTextView.text
        }
        set {
            guard let title = newValue else {
                titleTextView.text = nil
                return
            }

            titleTextView.attributedText = attributedText(from: title, font: Style.headlineFont, color: Style.headlineColor)
        }
    }

    /// Note's Body
    ///
    var bodyText: String? {
        get {
            bodyTextView.text
        }
        set {
            guard let body = newValue else {
                bodyTextView.text = nil
                return
            }

            bodyTextView.attributedText = attributedText(from: body, font: Style.previewFont, color: Style.previewColor)
        }
    }

    /// In condensed mode we simply won't render the bodyTextView
    ///
    var rendersInCondensedMode: Bool {
        get {
            bodyTextView.isHidden
        }
        set {
            bodyTextView.isHidden = newValue
        }
    }

    /// Returns the Preview's Fragment Padding
    ///
    var bodyLineFragmentPadding: CGFloat {
        return bodyTextView.textContainer.lineFragmentPadding
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
        setupTextViews()
        setupStackViews()
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
        titleTextView.textStorage.apply(color, toSubstringMatchingKeywords: keywords)
        bodyTextView.textStorage.apply(color, toSubstringMatchingKeywords: keywords)
    }
}


// MARK: - Private Methods: Initialization
//
private extension SPNoteTableViewCell {

    /// Setup: TextView
    ///
    func setupTextViews() {
        titleTextView.isAccessibilityElement = false
        titleTextView.textContainerInset = .zero

        bodyTextView.isAccessibilityElement = false
        bodyTextView.textContainerInset = .zero

        let titleTextContainer = titleTextView.textContainer
        titleTextContainer.maximumNumberOfLines = Style.maximumNumberOfTitleLines
        titleTextContainer.lineFragmentPadding = .zero
        titleTextContainer.lineBreakMode = .byWordWrapping

        let bodyTextContainer = bodyTextView.textContainer
        bodyTextContainer.maximumNumberOfLines = Style.maximumNumberOfBodyLines
        bodyTextContainer.lineFragmentPadding = .zero
        bodyTextContainer.lineBreakMode = .byWordWrapping
    }

    /// Setup: StackView
    ///
    func setupStackViews() {
        accessoryStackView.isLayoutMarginsRelativeArrangement = true
    }
}


// MARK: - Notifications
//
private extension SPNoteTableViewCell {

    /// Wires the (related) notifications to their handlers
    ///
    func startListeningToNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contentSizeCatoryWasUpdated),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
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
    }

    /// Accessory's StackView should be aligned against the PreviewTextView's first line center
    ///
    func refreshConstraints() {
        let lineHeight = Style.headlineFont.lineHeight
        let accessoryDimension = ceil(lineHeight * Style.accessoryImageSizeRatio)
        let cappedDimension = max(min(accessoryDimension, Style.accessoryImageMaximumSize), Style.accessoryImageMinimumSize)
        let accessoryPaddingTop = ceil((lineHeight - cappedDimension) * 0.5)

        accessoryStackView.layoutMargins = UIEdgeInsets(top: accessoryPaddingTop, left: 0, bottom: 0, right: 0)

        accessoryLeftImageViewHeightConstraint.constant = cappedDimension
        accessoryRightImageViewHeightConstraint.constant = cappedDimension
    }

    /// Refreshes Accessory ImageView(s) and StackView(s) visibility, as needed
    ///
    func refreshAccessoriesVisibility() {
        let isLeftImageEmpty = accessoryLeftImageView.image == nil
        let isRightImageEmpty = accessoryRightImageView.image == nil

        accessoryLeftImageView.isHidden = isLeftImageEmpty
        accessoryRightImageView.isHidden = isRightImageEmpty
        accessoryStackView.isHidden = isLeftImageEmpty && isRightImageEmpty
    }

    /// Returns a NSAttributedString instance representing a given String, with the specified Font and Color. We'll also process Checklists!
    ///
    func attributedText(from string: String, font: UIFont, color: UIColor) -> NSAttributedString {
        let output = NSMutableAttributedString(string: string, attributes: [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: Style.paragraphStyle
        ])

        output.addChecklistAttachments(for: color)
        return output
    }
}


// MARK: - Cell Styles
//
private enum Style {

    /// Accessory's Ratio (measured against Line Size)
    ///
    static let accessoryImageSizeRatio = CGFloat(0.75)

    /// Accessory's Minimum Size
    ///
    static let accessoryImageMinimumSize = CGFloat(16)

    /// Accessory's Maximum Size
    ///
    static let accessoryImageMaximumSize = CGFloat(24)

    /// Title's Maximum Lines
    ///
    static let maximumNumberOfTitleLines = 1

    /// Body's Maximum Lines
    ///
    static let maximumNumberOfBodyLines = 2

    /// TextView's paragraphStyle
    ///
    static let paragraphStyle: NSParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byTruncatingTail
        return style
    }()

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
