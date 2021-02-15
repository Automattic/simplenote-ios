import Foundation


// MARK: - InterlinkProcessorDelegate
//
protocol InterlinkProcessorDelegate: NSObjectProtocol {

    /// Invoked whenever an Autocomplete Row has been selected: The handler should insert the specified text at a given range
    ///
    func interlinkProcessor(_ processor: InterlinkProcessor, insert text: String, in range: Range<String.Index>)
}


// MARK: - InterlinkProcessor
//
class InterlinkProcessor: NSObject {

    private let viewContext: NSManagedObjectContext
    private let popoverPresenter: PopoverPresenter
    private let parentTextView: UITextView
    private let excludedEntityID: NSManagedObjectID

    private weak var interlinkViewController: InterlinkViewController?

    private var lastKnownEditorOffset: CGPoint?
    private var lastKnownKeywordRange: Range<String.Index>?
    private var initialEditorOffset: CGPoint?
    private lazy var resultsController = InterlinkResultsController(viewContext: viewContext)

    weak var delegate: InterlinkProcessorDelegate?

    /// Designated Initializer
    ///
    init(viewContext: NSManagedObjectContext,
         popoverPresenter: PopoverPresenter,
         parentTextView: UITextView,
         excludedEntityID: NSManagedObjectID) {
        self.viewContext = viewContext
        self.popoverPresenter = popoverPresenter
        self.parentTextView = parentTextView
        self.excludedEntityID = excludedEntityID
    }

    /// Displays the Interlink Lookup UI at the cursor's location when all of the following are **true**:
    ///
    ///     1.  The Editor isn't Undoing nor Highlighting
    ///     2.  The Editor is the first responder
    ///     3.  There is an interlink `[keyword` at the current location
    ///     4.  There are Notes with `keyword` in their title
    ///
    ///  Otherwise we'll simply dismiss the Autocomplete View, if any.
    ///
    @objc
    func processInterlinkLookup() {
        guard mustProcessInterlinkLookup,
              let (markdownRange, keywordRange, keywordText) = parentTextView.interlinkKeywordAtSelectedLocation,
              let notes = resultsController.searchNotes(byTitleKeyword: keywordText, excluding: excludedEntityID)
        else {
            dismissInterlinkLookup()
            return
        }

        showInterlinkController(with: notes, around: keywordRange)
        setupInterlinkEventListeners(replacementRange: markdownRange)

        initialEditorOffset = parentTextView.contentOffset
        lastKnownEditorOffset = parentTextView.contentOffset
        lastKnownKeywordRange = keywordRange
    }

    /// Dismisses the Interlink UI (if it's onscreen!)
    ///
    @objc
    func dismissInterlinkLookup() {
        popoverPresenter.dismiss()
        interlinkViewController = nil
    }
}


// MARK: - Presenting
//
private extension InterlinkProcessor {

    func showInterlinkController(with notes: [Note], around range: Range<String.Index>) {
        let keywordFrame = parentTextView.locationInWindowForText(in: range)

        guard !popoverPresenter.isPresented else {
            refreshInterlinkController(notes: notes)
            popoverPresenter.relocate(around: keywordFrame)
            return
        }

        let viewController = InterlinkViewController()
        interlinkViewController = viewController
        refreshInterlinkController(notes: notes)

        popoverPresenter.show(viewController,
                              around: keywordFrame,
                              desiredHeight: viewController.desiredHeight)

        SPTracker.trackEditorInterlinkAutocompleteViewed()
    }

    func refreshInterlinkController(notes: [Note]) {
        interlinkViewController?.notes = notes
    }

    func setupInterlinkEventListeners(replacementRange: Range<String.Index>) {
        interlinkViewController?.onInsertInterlink = { [weak self] text in
            guard let self = self else {
                return
            }

            self.delegate?.interlinkProcessor(self, insert: text, in: replacementRange)
        }
    }
}


// MARK: - Scrolling
//
extension InterlinkProcessor {

    /// Relocates the Interlink UI (whenever it's visible) to match the new TextView's Content Offset.
    /// - Important: Whenever the **Maximum Allowed Scroll Offset** is exceeded (and the scroll event is user initiated), we'll just dismiss the UI
    ///
    @objc(refreshInterlinkControllerWithNewOffset:isDragging:)
    func refreshInterlinkController(contentOffset: CGPoint, isDragging: Bool) {
        defer {
            lastKnownEditorOffset = contentOffset
        }

        guard let oldY = lastKnownEditorOffset?.y, let initialY = initialEditorOffset?.y else {
            return
        }

        popoverPresenter.relocate(by: oldY - contentOffset.y)
        if isDragging {
            dismissInterlinkLookupIfNeeded(initialY: initialY, currentY: contentOffset.y)
        }
    }

    /// Dismisses the Interlink Lookup whenever the **Maximum Allowed Scroll Offset** is exceeded
    ///
    private func dismissInterlinkLookupIfNeeded(initialY: CGFloat, currentY: CGFloat) {
        guard abs(currentY - initialY) > Settings.maximumAllowedScrollOffset else {
            return
        }

        dismissInterlinkLookup()
    }
}


// MARK: - State
//
private extension InterlinkProcessor {
    var mustProcessInterlinkLookup: Bool {
        let editor = parentTextView
        return editor.isFirstResponder && !editor.isTextSelected && !editor.isUndoingEditOP
    }
}


// MARK: - Settings
//
private enum Settings {
    static let maximumAllowedScrollOffset = CGFloat(20)
}
