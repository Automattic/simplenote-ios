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
        let lineHeight = Style.labelFont.lineHeight
        let accessoryDimension = ceil(lineHeight * Style.accessoryImageSizeRatio)
        let cappedDimension = max(min(accessoryDimension, Style.accessoryImageMaximumSize), Style.accessoryImageMinimumSize)

        leftImageHeightConstraint.constant = cappedDimension
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
        let verticalPadding: CGFloat = 12
        let lineHeight = UIFont.preferredFont(forTextStyle: .headline).lineHeight
        let result = 2.0 * verticalPadding + lineHeight

        return result.rounded(.up)
    }
}


// MARK: - Cell Styles
//
private enum Style {

    /// Accessory's Ratio (measured against Line Size)
    ///
    static let accessoryImageSizeRatio = CGFloat(0.70)

    /// Accessory's Minimum Size
    ///
    static let accessoryImageMinimumSize = CGFloat(24)

    /// Accessory's Maximum Size (1.5 the asset's size)
    ///
    static let accessoryImageMaximumSize = CGFloat(36)

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
        .simplenoteNoteHeadlineColor
    }

    /// Color to be applied over the cell upon selection
    ///
    static var selectionColor: UIColor {
        .simplenoteLightBlueColor
    }
}
