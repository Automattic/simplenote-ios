import Foundation
import UIKit


/// Tool that allows us to generate a snapshot (UIView) for animation purposes.
///
@objc
class SnapshotRenderer: NSObject {

    /// Editor TextView: We rely on this instance to render the Notes Editor.
    ///
    private let editorTextView: SPTextView = {
        let output = SPTextView()
        output.textContainerInset = .zero
        output.textContainer.lineFragmentPadding = .zero
        output.isScrollEnabled = false
        output.isEditable = false
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

        // Okay. We've got to talk. Why do we return an actual TableViewCell?
        // The answer is stunning. NoteTableViewCell uses Autolayout, and has different traits, based on the size classes.
        // So far so good.
        //
        // Now... unless you attach the Cell as a subview, there is simply no way to set the require Traits.
        // For that reason, rather than implementing hacks... we're opting for simply returning a new Instance each time.
        //
        let tableViewCell = SPNoteTableViewCell.instantiateFromNib() as SPNoteTableViewCell

        // Setup: iOS 13 Dark Mode
        ensureAppearanceMatchesSystem(view: tableViewCell)

        // Setup: Contents
        configure(tableViewCell: tableViewCell, note: note, searchQuery: searchQuery)

        // Setup: Layout
        tableViewCell.frame.size = size
        tableViewCell.layoutIfNeeded()

        return tableViewCell
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
        configure(editorTextView: editorTextView, note: note, searchQuery: searchQuery)

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

        view.overrideUserInterfaceStyle = UITraitCollection.current.userInterfaceStyle
    }

    /// Configures a given SPTextView instance in order to properly render a given Note, with the specified Search Query.
    ///
    func configure(editorTextView: SPTextView, note: Note, searchQuery: String?) {
        editorTextView.backgroundColor = .color(name: .backgroundColor)
        editorTextView.interactiveTextStorage.tokens = storageAttributes
        editorTextView.attributedText = attributedText(from: note.content)
        editorTextView.contentOffset = .zero

        if let searchQuery = searchQuery {
            editorTextView.highlightSubstrings(matching: searchQuery, color: .simplenoteTintColor)
        }
    }

    /// Configures a given SPNoteTableViewCell instance in order to properly render a given Note, with the specified Search Query.
    ///
    func configure(tableViewCell: SPNoteTableViewCell, note: Note, searchQuery: String?) {
        tableViewCell.titleText = note.titlePreview
        tableViewCell.bodyText = note.bodyPreview
        tableViewCell.accessoryLeftImage = note.published ? .image(name: .shared) : nil
        tableViewCell.accessoryRightImage = note.pinned ? .image(name: .pin) : nil
        tableViewCell.accessoryLeftTintColor = accessoryColor
        tableViewCell.accessoryRightTintColor = accessoryColor
        tableViewCell.rendersInCondensedMode = Options.shared.condensedNotesList

        if let searchQuery = searchQuery {
            tableViewCell.highlightSubstrings(matching: searchQuery, color: .simplenoteTintColor)
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

    /// Returns the Note's Status Image Color
    ///
    var accessoryColor: UIColor {
        return .simplenoteNoteStatusImageColor
    }

    /// Returns the (current) Body Color
    ///
    var bodyColor: UIColor {
        return .simplenoteNoteBodyPreviewColor
    }

    /// Returns the Body Font
    ///
    var bodyFont: UIFont {
        return .preferredFont(forTextStyle: .body)
    }

    /// Returns the (current) Headline Color
    ///
    var headlineColor: UIColor {
        return .simplenoteNoteHeadlineColor
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
