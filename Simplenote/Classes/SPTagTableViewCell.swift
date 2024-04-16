import Foundation
import UIKit

// MARK: - SPTagTableViewCell
//
@objcMembers
class SPTagTableViewCell: UITableViewCell {

    /// Left UIImageView
    ///
    @IBOutlet private var leftImageView: UIImageView!

    /// Left UIImageView's Height Constraint
    ///
    @IBOutlet private var leftImageHeightConstraint: NSLayoutConstraint!

    /// Tag Name's Label
    ///
    @IBOutlet private var nameLabel: UILabel!

    /// Spacing Width Constraint: We're matching the Note Cell's Leading metrics
    ///
    @IBOutlet private var spacingViewWidthConstraint: NSLayoutConstraint!

    /// Left Image
    ///
    var leftImage: UIImage? {
        get {
            leftImageView.image
        }
        set {
            leftImageView.image = newValue
        }
    }

    /// Left Image's Tint Color
    ///
    var leftImageTintColor: UIColor {
        get {
            leftImageView.tintColor
        }
        set {
            leftImageView.tintColor = newValue
        }
    }

    /// Note's Title
    ///
    var titleText: String? {
        get {
            nameLabel?.text
        }
        set {
            nameLabel?.text = newValue
        }
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
        refreshStyle()
        refreshConstraints()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        refreshStyle()
        refreshConstraints()
    }
}

// MARK: - Private Methods
//
private extension SPTagTableViewCell {

    /// Setup: Layout Margins
    ///
    func setupMargins() {
        // Note: This one affects the TableView's separatorInsets
        layoutMargins = .zero
    }

    /// Refreshes the current Style current style
    ///
    func refreshStyle() {
        nameLabel.textColor = Style.textColor
        backgroundColor = Style.backgroundColor

        let selectedView = UIView(frame: bounds)
        selectedView.backgroundColor = Style.selectionColor
        selectedBackgroundView = selectedView
    }

    /// Accessory's StackView should be aligned against the PreviewTextView's first line center
    ///
    func refreshConstraints() {
        let assetHeight = Style.labelFont.inlineAssetHeight()

        // What's the spacing about?
        // We're matching NoteTableViewCell's Left Spacing (which is where the Pinned Indicator goes).
        // Our goal is to have the Left Image's PositionX to match the Note Cell's title label
        //
        spacingViewWidthConstraint.constant = max(min(assetHeight, Style.spacingMaximumSize), Style.spacingMinimumSize)
        leftImageHeightConstraint.constant = max(min(assetHeight, Style.imageMaximumSize), Style.imageMinimumSize)
    }
}

// MARK: - Notifications
//
private extension SPTagTableViewCell {

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

// MARK: - Static!
//
extension SPTagTableViewCell {

    /// Returns the Height that the receiver would require to be rendered
    ///
    /// Note: Why these calculations? why not Autosizing cells?. Well... Performance.
    ///
    static var cellHeight: CGFloat {
        let lineHeight = UIFont.preferredFont(forTextStyle: .headline).lineHeight
        let padding = Style.padding
        let result = padding.top + lineHeight + padding.bottom

        return result.rounded(.up)
    }
}

// MARK: - Cell Styles
//
private enum Style {

    /// Accessory's Minimum Size
    ///
    static let imageMinimumSize = CGFloat(24)

    /// Accessory's Maximum Size (1.5 the asset's size)
    ///
    static let imageMaximumSize = CGFloat(36)

    /// Accessory's Minimum Size
    ///
    static let spacingMinimumSize = CGFloat(15)

    /// Accessory's Maximum Size (1.5 the asset's size)
    ///
    static let spacingMaximumSize = CGFloat(24)

    /// Tag(s) Cell Vertical Padding
    ///
    static let padding = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

    /// Returns the Cell's Background Color
    ///
    static var backgroundColor: UIColor {
        .simplenoteBackgroundColor
    }

    /// Headline Font: To be applied over the first preview line
    ///
    static var labelFont: UIFont {
        .preferredFont(forTextStyle: .body)
    }

    /// Headline Color: To be applied over the first preview line
    ///
    static var textColor: UIColor {
        .simplenoteTextColor
    }

    /// Color to be applied over the cell upon selection
    ///
    static var selectionColor: UIColor {
        .simplenoteLightBlueColor
    }
}
