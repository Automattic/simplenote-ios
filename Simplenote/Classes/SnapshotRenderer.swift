import Foundation
import UIKit


///
///
@objc
class SnapshotRenderer: NSObject {

    ///
    ///
    private var textView: SPTextView = {
        let output = SPTextView()
        output.textContainer.lineFragmentPadding = 0
        return output
    }()

    ///
    ///
    @objc
    func render(note: Note, size: CGSize, searchQuery: String?, preview: Bool) -> UIView {

        // Setup: TextView
        textView.frame.size = size
        textView.backgroundColor = theme.color(forKey: .backgroundColor)
        textView.interactiveTextStorage.tokens = [
            SPDefaultTokenName:     defaultAttributes(preview: preview),
            SPHeadlineTokenName:    headlineAttributes()
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

        // Render!
        textView.layoutManager.ensureLayout(forBoundingRect: UIScreen.main.bounds, in: textView.textContainer)

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
        return VSThemeManager.shared()!.theme()
    }

    /// Returns the TextView's Default Attributes
    ///
    func defaultAttributes(preview: Bool) -> [NSAttributedString.Key: Any] {
        if preview {
            return [
                .foregroundColor:   bodyColor,
                .font:              bodyFont
            ]
        }

        return [
            .foregroundColor:   headlineColor,
            .font:              bodyFont,
            .paragraphStyle:    paragraphStyle
        ]
    }

    /// Returns the TextView's Headline Attributes
    ///
    func headlineAttributes() -> [NSAttributedString.Key: Any] {
        return [
            .foregroundColor:   headlineColor,
            .font:              headlineFont
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

    /// Maximum Text Length on iPhone / iPad Devices
    ///
    static let maximumLengthPhone  = 1200
    static let maximumLengthPad    = 3100

    /// Returns the Maximum Length of a snapshot, for the current device.
    /// NOTE: Why don't we use Size Classes? Because on iPad Multitasking we may get compact width. And we want
    /// the same maximum length for iPads, regardless of the UIWindow's width.
    ///
    static var maximumLength: Int {
        return UIDevice.sp_isPad() ? maximumLengthPad : maximumLengthPhone
    }
}
