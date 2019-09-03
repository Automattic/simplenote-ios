import Foundation
import UIKit


// MARK: - SPNoteTableViewCell
//
@objcMembers
class SPNoteTableViewCell: UITableViewCell {

    /// TextView to act as Note's Text container
    ///
    private lazy var previewTextView: SPTextView = {
        let textView = SPTextView()
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = false
        textView.isEditable = false
        textView.isAccessibilityElement = false
        textView.backgroundColor = .clear

        let container = textView.textContainer
        container.maximumNumberOfLines = 3
        container.lineFragmentPadding = 0
        container.lineBreakMode = .byWordWrapping
        return textView
    }()

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

    ///
    ///
    var accessoryImage: UIImage?

    ///
    ///
    var accessoryTintColor: UIColor?


    /// Designated Initializer
    ///
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
        refreshStyle()
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
}


// MARK: - Cell Styles
//
private enum Style {

    /// Returns the Cell's Background Color
    ///
    static var backgroundColor: UIColor {
        return .color(name: .backgroundColor)!
    }

    /// Headline Color: To be applied over the first preview line
    ///
    static var headlineColor: UIColor {
        return UIColor.color(name: .noteHeadlineFontColor)!
    }

    /// Headline Font: To be applied over the first preview line
    ///
    static var headlineFont: UIFont {
        return UIFont.preferredFont(forTextStyle: .headline)
    }

    /// Preview Color: To be applied over  the preview's body (everything minus the first line)
    ///
    static var previewColor: UIColor {
        return .color(name: .noteBodyFontPreviewColor)!
    }

    /// Preview Font: To be applied over  the preview's body (everything minus the first line)
    ///
    static var previewFont: UIFont {
        return UIFont.preferredFont(forTextStyle: .body)
    }

    /// Color to be applied over the cell upon selection
    ///
    static var selectionColor: UIColor {
        return .color(name: .lightBlueColor)!
    }
}
