import Foundation
import UIKit


//
//
@objcMembers
class SPNoteTableViewCell: UITableViewCell {

    ///
    ///
    override var backgroundColor: UIColor? {
        didSet {
            refreshBackgrounds()
        }
    }

    ///
    ///
    private lazy var previewTextView: SPTextView = {
        let textView = SPTextView()
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = false
        textView.isEditable = false
        textView.isAccessibilityElement = false
        let container = textView.textContainer
        container.maximumNumberOfLines = 3
        container.lineFragmentPadding = 0
        container.lineBreakMode = .byWordWrapping
        return textView
    }()

    ///
    ///
    var previewText: NSAttributedString? {
        get {
            return previewTextView.attributedText
        }
        set {
            previewTextView.attributedText = newValue
        }
    }

    ///
    ///
    var previewAlpha: CGFloat = 0

    ///
    ///
    var accessoryImage: UIImage?

    ///
    ///
    var accessoryTintColor: UIColor?


    ///
    ///
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
        applyStyle()
    }


    ///
    ///
    func highlightSubstrings(matching string: String, color: UIColor) {
//        [cell.previewView.textStorage applyColorAttribute:tintColor
//                                                forRanges:[cell.previewView.text rangesForTerms:_searchText]];
    }
}


// MARK: - Private Methods: Initialization
//
private extension SPNoteTableViewCell {

    func setupSubviews() {
        previewTextView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(previewTextView)

        let layoutGuide = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            previewTextView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            previewTextView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
            previewTextView.topAnchor.constraint(equalTo: contentView.topAnchor),
            previewTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            ])
    }
}


// MARK: - Private Methods: Skinning
//
private extension SPNoteTableViewCell {

    ///
    ///
    func applyStyle() {
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

    ///
    ///
    func refreshBackgrounds() {
        contentView.backgroundColor = backgroundColor
        previewTextView.backgroundColor = backgroundColor
    }
}


// MARK: -
//
private enum Style {

    ///
    ///
    static var backgroundColor: UIColor {
        return .color(name: .backgroundColor)!
    }

    ///
    ///
    static var headlineColor: UIColor {
        return UIColor.color(name: .noteHeadlineFontColor)!
    }

    ///
    ///
    static var headlineFont: UIFont {
        return UIFont.preferredFont(forTextStyle: .headline)
    }

    ///
    ///
    static var previewColor: UIColor {
        return .color(name: .noteBodyFontPreviewColor)!
    }

    ///
    ///
    static var previewFont: UIFont {
        return UIFont.preferredFont(forTextStyle: .body)
    }

    ///
    ///
    static var selectionColor: UIColor {
        return .color(name: .lightBlueColor)!
    }
}
