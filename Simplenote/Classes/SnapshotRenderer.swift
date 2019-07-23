import Foundation
import UIKit


/// Tool that allows us to generate a snapshot (UIView) for animation purposes.
///
@objc
class SnapshotRenderer: NSObject {

    /// Rendering TextView
    ///
    private lazy var textView: SPTextView = {
        let output = SPTextView()
        output.addSubview(self.accessoryImageView)
        output.textContainer.lineFragmentPadding = 0
        return output
    }()

    /// Rendering AccessoryImageView
    ///
    private lazy var accessoryImageView: UIImageView = {
        let output = UIImageView()
        output.contentMode = .center
        return output
    }()


    /// Returns a UIView representation of a given Note, with the specified parameters:
    ///
    /// - Parameter:
    ///     - note: The entity we're about to render
    ///     - size: Output UIView's size
    ///     - searchQuery: Search String (if any) that should be highlighted
    ///     - preview: Indicates if the screenshot will be used to represent the Note List Cell, or the full editor
    ///
    /// - Returns: UIImageView containing a UIImage representation of the Note.
    ///
    @objc
    func render(note: Note, size: CGSize, searchQuery: String?, preview: Bool) -> UIView {
        // Setup: Skin
        let backgroundColor = theme.color(forKey: .backgroundColor)
        accessoryImageView.backgroundColor = backgroundColor
        textView.backgroundColor = backgroundColor
        textView.interactiveTextStorage.tokens = [
            SPDefaultTokenName: defaultAttributes(preview: preview),
            SPHeadlineTokenName: headlineAttributes()
        ]

        // Setup: Payload
        let tintColor = searchQuery != nil ? bodyColor : headlineColor
        textView.attributedText = attributedText(for: note, preview: preview, attachmentsTintColor: tintColor)

        // Setup: Highlighted Keywords
        if let searchQuery = searchQuery {
            let color = theme.color(forKey: .tintColor)
            let ranges = (textView.text as NSString).ranges(forTerms: searchQuery)

            textView.textStorage.applyColorAttribute(color, forRanges: ranges)
        }

        // Setup: AccessoryImage
        let accessoryImage = note.published && preview ? UIImage.sharedImage.withRenderingMode(.alwaysTemplate) : nil
        let accessorySize = accessoryImage?.size ?? CGSize.zero

        accessoryImageView.image = accessoryImage
        accessoryImageView.tintColor = bodyColor
        accessoryImageView.sizeToFit()

        // Setup: Layout
        textView.frame.size = size
        textView.textContainerInset.right = preview ? accessorySize.width + Constants.accessoryImageViewPadding.left: 0

        accessoryImageView.frame.origin.x = size.width - accessorySize.width
        accessoryImageView.frame.origin.y = accessorySize.height

        textView.layoutIfNeeded()

        // Setup: Render
        guard let snapshot = textView.imageRepresentationWithinImageView() else {
            fatalError()
        }

        snapshot.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        return snapshot
    }
}


// MARK: - Private dynamic properties
//
private extension SnapshotRenderer {

    /// Returns the (current) Body Color
    ///
    var bodyColor: UIColor {
        return theme.color(forKey: .noteBodyFontPreviewColor)!
    }

    /// Returns the Body Font
    ///
    var bodyFont: UIFont {
        return UIFont.preferredFont(forTextStyle: .body)
    }

    /// Returns the (current) Headline Color
    ///
    var headlineColor: UIColor {
        return theme.color(forKey: .noteHeadlineFontColor)!
    }

    /// Returns the Headline Font
    ///
    var headlineFont: UIFont {
        return UIFont.preferredFont(forTextStyle: .headline)
    }

    /// Returns the TextView's Paragraph Style
    ///
    var paragraphStyle: NSParagraphStyle {
        let style =  NSMutableParagraphStyle()
        style.lineSpacing = bodyFont.lineHeight * theme.float(forKey: .noteBodyLineHeightPercentage)
        return style
    }

    /// Returns the current Theme. Eventually... nuke this please!
    ///
    var theme: VSTheme {
        return VSThemeManager.shared().theme()
    }

    /// Returns the TextView's Default Attributes
    ///
    func defaultAttributes(preview: Bool) -> [NSAttributedString.Key: Any] {
        if preview {
            return [
                .foregroundColor: bodyColor,
                .font: bodyFont
            ]
        }

        return [
            .foregroundColor: headlineColor,
            .font: bodyFont,
            .paragraphStyle: paragraphStyle
        ]
    }

    /// Returns the TextView's Headline Attributes
    ///
    func headlineAttributes() -> [NSAttributedString.Key: Any] {
        return [
            .foregroundColor: headlineColor,
            .font: headlineFont
        ]
    }

    /// Returns a NSMutableAttributedString instance representing a given note:
    ///
    /// - Note: Checklist and Pinned Attachments are inserted, when appropriate.
    ///
    func attributedText(for note: Note, preview: Bool, attachmentsTintColor: UIColor) -> NSAttributedString {
        guard let text = (preview ? note.preview : note.content) else {
            return NSAttributedString()
        }

        let trimmedText = String(text.prefix(Constants.maximumLength))
        let output = NSMutableAttributedString(string: trimmedText)

        // Attachments: Checklists
        output.addChecklistAttachments(for: bodyColor)

        // Attachments: Pinned!
        guard note.pinned, preview, let pinImage = UIImage.pinImage.withOverlayColor(attachmentsTintColor) else {
            return output
        }

        return output.withLeading(pinImage, lineHeight: headlineFont.capHeight)
    }
}



// MARK: - Constants
//
private struct Constants {

    /// Insets to be applied over the AccessoryImageView
    ///
    static let accessoryImageViewPadding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)

    /// Maximum Text Length on iPhone / iPad Devices
    ///
    static let maximumLengthPhone = 1200
    static let maximumLengthPad = 3100

    /// Returns the Maximum Length of a snapshot, for the current device.
    /// NOTE: Why don't we use Size Classes? Because on iPad Multitasking we may get compact width. And we want
    /// the same maximum length for iPads, regardless of the UIWindow's width.
    ///
    static var maximumLength: Int {
        return UIDevice.sp_isPad() ? maximumLengthPad : maximumLengthPhone
    }
}
