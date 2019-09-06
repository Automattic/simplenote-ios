import Foundation
import UIKit


/// Tool that allows us to generate a snapshot (UIView) for animation purposes.
///
@objc
class SnapshotRenderer: NSObject {

    /// Note Cell: We rely on this instance to render cells from the Notes List.
    ///
    private let noteTableViewCell = SPNoteTableViewCell.instantiateFromNib() as SPNoteTableViewCell

    /// Editor TextView: We rely on this instance to render the Notes Editor.
    ///
    private let editorTextView: SPTextView = {
        let output = SPTextView()
        output.textContainerInset = .zero
        output.textContainer.lineFragmentPadding = .zero
        return output
    }()


    /// Returns a Preview Snapshot (Notes List!) representation of a given Note.
    ///
    /// - Parameters:
    ///     -   note:           The entity we're about to render
    ///     -   size:           Output UIView's size
    ///     -   searchQuery:    Search String (if any) that should be highlighted
    ///
    @objc
    func renderPreviewSnapshot(for note: Note, size: CGSize, searchQuery: String?) -> UIView {

        // Setup: iOS 13 Dark Mode
        ensureAppearanceMatchesSystem(view: noteTableViewCell)

        // Setup: Contents
        configureTableViewCell(tableViewCell: noteTableViewCell, note: note, searchQuery: searchQuery)

        // Setup: Layout
        let targetView = noteTableViewCell
        targetView.frame.size = size
        targetView.layoutIfNeeded()

        // Setup: Render
        let snapshot = targetView.imageRepresentationWithinImageView()
        snapshot.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        return snapshot
    }

    /// Returns an Editor Snapshot representation of a given Note.
    ///
    /// - Parameters:
    ///     -   note:           The entity we're about to render
    ///     -   size:           Output UIView's size
    ///     -   searchQuery:    Search String (if any) that should be highlighted
    ///
    @objc
    func renderEditorSnapshot(for note: Note, size: CGSize, searchQuery: String?) -> UIView {

        // Setup: iOS 13 Dark Mode
        ensureAppearanceMatchesSystem(view: editorTextView)

        // Setup: Contents
        configureEditorTextView(textView: editorTextView, note: note, searchQuery: searchQuery)

        // Setup: Layout
        let targetView = editorTextView
        targetView.frame.size = size
        targetView.layoutIfNeeded()

        // Setup: Render
        let snapshot = targetView.imageRepresentationWithinImageView()
        snapshot.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        return snapshot
    }
}

// MARK: - Private Methods
//
private extension SnapshotRenderer {

    /// Sets our rendering TextView's Override User Interface
    ///
    func ensureAppearanceMatchesSystem(view: UIView) {
        guard #available(iOS 13, *) else {
            return
        }

#if IS_XCODE_11
        view.overrideUserInterfaceStyle = UITraitCollection.current.userInterfaceStyle
#endif
    }

    /// Configures a given SPTextView instance in order to properly render a given Note, with the specified Search Query.
    ///
    func configureEditorTextView(textView: SPTextView, note: Note, searchQuery: String?) {
        textView.backgroundColor = .color(name: .backgroundColor)
        textView.interactiveTextStorage.tokens = storageAttributes
        textView.attributedText = attributedText(from: note.content)

        if let searchQuery = searchQuery {
            textView.highlightSubstrings(matching: searchQuery, color: .color(name: .tintColor)!)
        }
    }

    /// Configures a given SPNoteTableViewCell instance in order to properly render a given Note, with the specified Search Query.
    ///
    func configureTableViewCell(tableViewCell: SPNoteTableViewCell, note: Note, searchQuery: String?) {
        tableViewCell.prepareForReuse()
        tableViewCell.previewText = attributedText(from: note.preview)
        tableViewCell.accessoryLeftImage = note.published ? .image(name: .sharedImage) : nil
        tableViewCell.accessoryRightImage = note.pinned ? .image(name: .pinImage) : nil
        tableViewCell.accessoryLeftTintColor = bodyColor
        tableViewCell.accessoryRightTintColor = bodyColor
        tableViewCell.numberOfPreviewLines = Options.shared.numberOfPreviewLines

        if let searchQuery = searchQuery {
            tableViewCell.highlightSubstrings(matching: searchQuery, color: .color(name: .tintColor)!)
        }
    }

    /// Returns a NSMutableAttributedString instance representing a given note:
    ///
    /// - Note: Checklist and Pinned Attachments are inserted, when appropriate.
    ///
    func attributedText(from text: String?) -> NSAttributedString {
        guard let text = text else {
            return NSAttributedString()
        }

        let trimmedText = String(text.prefix(Constants.maximumLength))
        let output = NSMutableAttributedString(string: trimmedText)

        output.addChecklistAttachments(for: bodyColor)

        return output
    }
}


// MARK: - Private dynamic properties
//
private extension SnapshotRenderer {

    /// Returns the (current) Body Color
    ///
    var bodyColor: UIColor {
        return .color(name: .noteBodyFontPreviewColor)!
    }

    /// Returns the Body Font
    ///
    var bodyFont: UIFont {
        return .preferredFont(forTextStyle: .body)
    }

    /// Returns the (current) Headline Color
    ///
    var headlineColor: UIColor {
        return .color(name: .noteHeadlineFontColor)!
    }

    /// Returns the Headline Font
    ///
    var headlineFont: UIFont {
        return .preferredFont(forTextStyle: .headline)
    }

    /// Returns the TextView's Paragraph Style
    ///
    var paragraphStyle: NSParagraphStyle {
        let theme = VSThemeManager.shared().theme()
        let style =  NSMutableParagraphStyle()
        style.lineSpacing = bodyFont.lineHeight * theme.float(forKey: "noteBodyLineHeightPercentage")
        return style
    }

    /// Returns the TextView's Headline Attributes
    ///
    var storageAttributes: [String: [NSAttributedString.Key: Any]] {
        return [
            SPHeadlineTokenName: [
                .foregroundColor: headlineColor,
                .font: headlineFont
            ],
            SPDefaultTokenName: [
                .foregroundColor: headlineColor,
                .font: bodyFont,
                .paragraphStyle: paragraphStyle
            ]
        ]
    }
}


// MARK: - Constants
//
private struct Constants {

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
