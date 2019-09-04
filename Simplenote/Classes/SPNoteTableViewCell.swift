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

    /// TextView to act as Note's Text container
    ///
    private lazy var previewTextView = SPTextView()

    /// Note's Accessory ImageView
    ///
    private lazy var accessoryImageView = UIImageView()

    /// Accessory Image
    ///
    var accessoryImage: UIImage? {
        get {
            return accessoryImageView.image
        }
        set {
            accessoryImageView.image = newValue
            refreshTextViewInsets()
        }
    }

    /// Accessory Image's Tint
    ///
    var accessoryTintColor: UIColor? {
        get {
            return accessoryImageView.tintColor
        }
        set {
            accessoryImageView.tintColor = newValue
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

    /// Note's Text Alpha Value
    ///
    var previewAlpha: CGFloat {
        get {
            return previewTextView.alpha
        }
        set {
            previewTextView.alpha = newValue
        }
    }

    /// Returns the Preview's Fragment Padding
    ///
    var previewLineFragmentPadding: CGFloat {
        return previewTextView.textContainer.lineFragmentPadding
    }


    /// Designated Initializer
    ///
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Overridden Methods

    override func awakeFromNib() {
        super.awakeFromNib()
        setupTextView()
        setupImageView()
        setupSubviews()
        setupStackView()
        refreshStyle()
    }


    ///

    // TODO: Nuke
    @objc
    func previewFrame(in view: UIView) -> CGRect {
        return view.convert(previewTextView.frame, from: previewTextView)
    }

    /// Highlights the partial matches with the specified color.
    ///
    func highlightSubstrings(matching keywords: String, color: UIColor) {
        previewTextView.textStorage.apply(color, toSubstringMatchingKeywords: keywords)
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
        container.lineFragmentPadding = 0
        container.lineBreakMode = .byWordWrapping
    }

    /// Setup: ImageView
    ///
    func setupImageView() {
        accessoryImageView.contentMode = .center
    }

    /// Setup: StackView
    ///
    func setupStackView() {
        accessoryStackView.addArrangedSubview(accessoryImageView)
    }

    /// Autolayout Init
    ///
    func setupSubviews() {
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


// MARK: - Private Methods: Skinning
//
private extension SPNoteTableViewCell {

    /// Applies the current style
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

    /// Applies the TextView Insets, based on the accessoryStack's Width
    ///
    func refreshTextViewInsets() {
        let width = accessoryImageView.image?.size.width ?? CGFloat.zero
        previewTextView.textContainerInset.right = width + Style.previewInsets.right
    }
}


// MARK: - Cell Styles
//
private enum Style {

    /// Preview's Text Insets
    ///
    static let previewInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)

    /// Returns the Cell's Background Color
    ///
    static var backgroundColor: UIColor {
        return .color(name: .backgroundColor)!
    }

    /// Headline Color: To be applied over the first preview line
    ///
    static var headlineColor: UIColor {
        return .color(name: .noteHeadlineFontColor)!
    }

    /// Headline Font: To be applied over the first preview line
    ///
    static var headlineFont: UIFont {
        return .preferredFont(forTextStyle: .headline)
    }

    /// Preview Color: To be applied over  the preview's body (everything minus the first line)
    ///
    static var previewColor: UIColor {
        return .color(name: .noteBodyFontPreviewColor)!
    }

    /// Preview Font: To be applied over  the preview's body (everything minus the first line)
    ///
    static var previewFont: UIFont {
        return .preferredFont(forTextStyle: .body)
    }

    /// Color to be applied over the cell upon selection
    ///
    static var selectionColor: UIColor {
        return .color(name: .lightBlueColor)!
    }
}
