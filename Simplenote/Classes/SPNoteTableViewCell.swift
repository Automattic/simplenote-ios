import Foundation
import UIKit


// MARK: - SPNoteTableViewCell
//
@objcMembers
class SPNoteTableViewCell: UITableViewCell {

    /// Title Label
    ///
    @IBOutlet private var titleLabel: UILabel!

    /// Body Label
    ///
    @IBOutlet private var bodyLabel: UILabel!

    /// Note's Left Accessory ImageView
    ///
    @IBOutlet private var accessoryLeftImageView: UIImageView!

    /// Note's Right Accessory ImageView
    ///
    @IBOutlet private var accessoryRightImageView: UIImageView!

    /// Multi Select Checkbox ImageView
    ///
    @IBOutlet private weak var multiSelectCheckbox: UIImageView!

    @IBOutlet private weak var checkboxContainingView: UIView!

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

    /// Multi select image
    ///
    var multiSelectionCheckboxImage: UIImage? {
        isSelected ? .image(name: .taskChecked) : .image(name: .taskUnchecked)
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

    /// Multi select image tint
    ///
    var multiSelectTintColor: UIColor? {
        get {
            multiSelectCheckbox.tintColor
        }
        set {
            multiSelectCheckbox.tintColor = newValue
        }
    }

    /// Highlighted Keywords
    /// - Note: Once the cell is fully initialized, please remember to run `refreshAttributedStrings`
    ///
    var keywords: [String]?

    /// Highlighted Keywords's Tint Color
    /// - Note: Once the cell is fully initialized, please remember to run `refreshAttributedStrings`
    ///
    var keywordsTintColor: UIColor = .simplenoteTintColor

    /// Note's Title
    /// - Note: Once the cell is fully initialized, please remember to run `refreshAttributedStrings`
    ///
    var titleText: String?

    /// Body's Prefix: Designed to display Dates (with a slightly different style) when appropriate.
    ///
    var prefixText: String?

    /// Note's Body
    /// - Note: Once the cell is fully initialized, please remember to run `refreshAttributedStrings`
    ///
    var bodyText: String?

    /// In condensed mode we simply won't render the bodyTextView
    ///
    var rendersInCondensedMode: Bool {
        get {
            bodyLabel.isHidden
        }
        set {
            bodyLabel.isHidden = newValue
        }
    }

    /// Returns the Preview's Fragment Padding
    ///
    var bodyLineFragmentPadding: CGFloat {
        .zero
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
        setupMargins()
        setupTextViews()
        setupMultiCheckbox()
        refreshStyle()
        refreshConstraints()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        refreshStyle()
        refreshConstraints()
    }

    func refreshEdgeInsets(editing: Bool = false) {
        var insets = SPNoteTableViewCell.separatorInsets
        insets.left -= layoutMargins.left
        insets.left += editing ? checkboxContainingView.frame.width : .zero

        separatorInset = insets
    }

    /// Refreshed the Label(s) Attributed Strings: Keywords, Bullets and the Body Prefix will be taken into consideration
    ///
    func refreshAttributedStrings() {
        refreshTitleAttributedString()
        refreshBodyAttributedString()
    }

    /// Refreshes the Title AttributedString: We'll consider Keyword Highlight and Text Attachments (bullets)
    ///
    private func refreshTitleAttributedString() {
        titleLabel.attributedText = titleText.map {
            NSAttributedString.previewString(from: $0,
                                             font: Style.headlineFont,
                                             textColor: Style.headlineColor,
                                             highlighing: keywords,
                                             highlightColor: keywordsTintColor,
                                             paragraphStyle: Style.paragraphStyle)

        }

    }

    /// Refreshes the Body AttributedString: We'll consider Keyword Highlight and Text Attachments (bullets)
    ///
    /// - Note: The `prefixText`, if any, will be prepended to the BodyText
    ///
    private func refreshBodyAttributedString() {
        let bodyString = NSMutableAttributedString()
        if let prefixText = prefixText {
            let prefixString = NSAttributedString(string: prefixText + String.space, attributes: [
                .font: Style.prefixFont,
                .foregroundColor: Style.headlineColor,
                .paragraphStyle: Style.paragraphStyle,
            ])

            bodyString.append(prefixString)
        }

        if let suffixText = bodyText {
            let suffixString = NSAttributedString.previewString(from: suffixText,
                                                                font: Style.previewFont,
                                                                textColor: Style.previewColor,
                                                                highlighing: keywords,
                                                                highlightColor: keywordsTintColor,
                                                                paragraphStyle: Style.paragraphStyle)
            bodyString.append(suffixString)
        }

        bodyLabel.attributedText = bodyString
    }

    func setMultiSelectEditing(_ editing: Bool) {
        UIView.animate(
            withDuration: UIKitConstants.animationQuickDuration,
            animations: {
                self.refreshEdgeInsets(editing: editing)
                self.checkboxContainingView.isHidden = !editing
                self.contentView.layoutIfNeeded()
            })

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        multiSelectCheckbox.image = multiSelectionCheckboxImage
    }
}


// MARK: - Private Methods: Initialization
//
private extension SPNoteTableViewCell {

    /// Setup: Layout Margins
    ///
    func setupMargins() {
        // Note: This one affects the TableView's separatorInsets
        layoutMargins = .zero
    }

    /// Setup: TextView
    ///
    func setupTextViews() {
        titleLabel.isAccessibilityElement = false
        bodyLabel.isAccessibilityElement = false

        titleLabel.numberOfLines = Style.maximumNumberOfTitleLines
        titleLabel.lineBreakMode = .byWordWrapping

        bodyLabel.numberOfLines = Style.maximumNumberOfBodyLines
        bodyLabel.lineBreakMode = .byWordWrapping
    }

    func setupMultiCheckbox() {
        multiSelectCheckbox.translatesAutoresizingMaskIntoConstraints = false
        multiSelectCheckbox.image = multiSelectionCheckboxImage
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
        let dimension = Style.accessoryImageDimension

        accessoryLeftImageViewHeightConstraint.constant = dimension
        accessoryRightImageViewHeightConstraint.constant = dimension
    }

    /// Refreshes Accessory ImageView(s) and StackView(s) visibility, as needed
    ///
    func refreshAccessoriesVisibility() {
        let isRightImageEmpty = accessoryRightImageView.image == nil

        accessoryRightImageView.isHidden = isRightImageEmpty
    }
}


// MARK: - SPNoteTableViewCell
//
extension SPNoteTableViewCell {

    /// TableView's Separator Insets: Expected to align **exactly** with the label(s) Leading.
    /// In order to get the TableView to fully respect this the following must be fulfilled:
    ///
    ///     1.  tableViewCell(s).layoutMargins = .zero
    ///     2.  tableView.layoutMargins = .zero
    ///     2.  tableView.separatorInsetReference = `.fromAutomaticInsets
    ///
    /// Then, and only then, this will work ferpectly 🔥
    ///
    @objc
    static var separatorInsets: UIEdgeInsets {
        let left = Style.containerInsets.left + Style.accessoryImageDimension + Style.accessoryImagePaddingRight
        return UIEdgeInsets(top: .zero, left: left, bottom: .zero, right: .zero)
    }

    /// Returns the Height that the receiver would require to be rendered, given the current User Settings (number of preview lines).
    ///
    /// Note: Why these calculations? why not Autosizing cells?. Well... Performance.
    ///
    @objc
    static var cellHeight: CGFloat {
        let numberLines = Options.shared.numberOfPreviewLines
        let lineHeight = UIFont.preferredFont(forTextStyle: .headline).lineHeight

        let paddingBetweenLabels = Options.shared.condensedNotesList ? .zero : Style.outerVerticalStackViewSpacing
        let insets = Style.containerInsets

        let result = insets.top + paddingBetweenLabels + CGFloat(numberLines) * lineHeight + insets.bottom

        return max(result.rounded(.up), Constants.minCellHeight)
    }
}


// MARK: - Cell Styles
//
private enum Style {

    /// Accessory's Dimension, based on the (current) Headline Font Size
    ///
    static var accessoryImageDimension: CGFloat {
        max(min(headlineFont.inlineAssetHeight(), accessoryImageMaximumSize), accessoryImageMinimumSize)
    }

    /// Accessory's Minimum Size
    ///
    static let accessoryImageMinimumSize = CGFloat(16)

    /// Accessory's Maximum Size (1.5 the asset's size)
    ///
    static let accessoryImageMaximumSize = CGFloat(24)

    /// Accessory's Right Padding
    ///
    static let accessoryImagePaddingRight = CGFloat(6)

    /// Title's Maximum Lines
    ///
    static let maximumNumberOfTitleLines = 1

    /// Body's Maximum Lines
    ///
    static let maximumNumberOfBodyLines = 2

    /// Represents the Insets applied to the container view
    ///
    static let containerInsets = UIEdgeInsets(top: 9, left: 6, bottom: 9, right: 0)

    /// Outer Vertical StackView's Spacing
    ///
    static let outerVerticalStackViewSpacing = CGFloat(2)

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
        .simplenoteBackgroundColor
    }

    /// Headline Color: To be applied over the first preview line
    ///
    static var headlineColor: UIColor {
        .simplenoteTextColor
    }

    /// Headline Font: To be applied over the first preview line
    ///
    static var headlineFont: UIFont {
        .preferredFont(forTextStyle: .headline)
    }

    /// Preview Color: To be applied over  the preview's body (everything minus the first line)
    ///
    static var previewColor: UIColor {
        .simplenoteNoteBodyPreviewColor
    }

    /// Preview Font: To be applied over  the preview's body (everything minus the first line)
    ///
    static var previewFont: UIFont {
        .preferredFont(forTextStyle: .subheadline)
    }

    /// Prefix Font: To be applied over the Body's Prefix (if any)
    ///
    static var prefixFont: UIFont {
        .preferredFont(for: .subheadline, weight: .medium)
    }

    /// Color to be applied over the cell upon selection
    ///
    static var selectionColor: UIColor {
        .simplenoteLightBlueColor
    }
}



// MARK: - NSAttributedString Private Methods
//
private extension NSAttributedString {

    /// Returns a NSAttributedString instance, stylizing the receiver with the current Highlighted Keywords + Font + Colors
    ///
    static func previewString(from string: String,
                              font: UIFont,
                              textColor: UIColor,
                              highlighing keywords: [String]?,
                              highlightColor: UIColor,
                              paragraphStyle: NSParagraphStyle) -> NSAttributedString {
        let output = NSMutableAttributedString(string: string, attributes: [
            .font: font,
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle,
        ])

        output.processChecklists(with: textColor, sizingFont: font, allowsMultiplePerLine: true)

        if let keywords = keywords, !keywords.isEmpty {
            output.apply(color: highlightColor, toSubstringsMatching: keywords)
        }

        return output
    }
}

// MARK: - Constants
//
private struct Constants {
    static let minCellHeight: CGFloat = 44
}
