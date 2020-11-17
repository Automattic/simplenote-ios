import Foundation



// MARK: - InterlinkPresentationContextProvider
//
protocol InterlinkProcessorPresentationContextProvider: NSObjectProtocol {

    /// View in the parent's hierarchy that should always appear above the Autocomplete UI
    ///
    func parentOverlayViewForInterlinkProcessor(_ processor: InterlinkProcessor) -> UIView

    /// Parent TextView that is triggering the Autocomplete event
    ///
    func parentTextViewForInterlinkProcessor(_ processor: InterlinkProcessor) -> UITextView

    /// Parent ViewController!
    ///
    func parentViewControllerForInterlinkProcessor(_ processor: InterlinkProcessor) -> UIViewController
}


// MARK: - InterlinkProcessorDelegate
//
protocol InterlinkProcessorDelegate: NSObjectProtocol {

    /// Invoked whenever an Autocomplete Row has been selected: The handler should insert the specified text at a given range
    ///
    func interlinkProcessor(_ processor: InterlinkProcessor, insert text: String, in range: Range<String.Index>)

    /// Represents the Entity that should be excluded when presenting Autocomplete results
    ///
    func excludedEntityIdentifierForInterlinkProcessor(_ processor: InterlinkProcessor) -> NSManagedObjectID?
}


// MARK: - InterlinkProcessor
//
class InterlinkProcessor: NSObject {

    private let viewContext: NSManagedObjectContext
    private var presentedViewController: InterlinkViewController?
    private var lastKnownEditorOffset: CGPoint?
    private var initialEditorOffset: CGPoint?
    private lazy var resultsController = InterlinkResultsController(viewContext: viewContext)

    weak var contextProvider: InterlinkProcessorPresentationContextProvider?
    weak var delegate: InterlinkProcessorDelegate?

    /// Designated Initializer
    ///
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }

    /// Displays the Interlink Lookup UI at the cursor's location when all of the following are **true**:
    ///
    ///     1. The Editor isn't Undoing nor Highlighting
    ///     2. The Editor is the first responder
    ///     3. There is an interlink `[keyword` at the current location
    ///     4. There are Notes with `keyword` in their title
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

        ensureInterlinkControllerIsOnScreen()
        refreshInterlinkController(notes: notes)
        relocateInterlinkController(around: keywordRange)
        trackLastKnownScrollOffsets()
        setupInterlinkEventListeners(replacementRange: markdownRange)
    }

    /// Dismisses the Interlink UI when ANY of the following evaluates **true**:
    ///
    ///     1.  There is Highlighted Text in the editor (or)
    ///     2.  There is no Interlink `[keyword` at the selected location
    ///     3.  The editor is being dragged
    ///     4.  The editor is no longer the first responder
    ///
    @objc
    func dismissInterlinkLookupIfNeeded() {
        guard isInterlinkLookupOnScreen, mustDismissInterlinkLookup else {
            return
        }

        dismissInterlinkLookup()
    }

    /// Dismisses the Interlink UI (if it's onscreen!)
    ///
    @objc
    func dismissInterlinkLookup() {
        presentedViewController?.detachWithAnimation()
        presentedViewController = nil
    }
}


// MARK: - Presenting
//
private extension InterlinkProcessor {

    func ensureInterlinkControllerIsOnScreen() {
        guard presentedViewController == nil else {
            return
        }

        presentInterlinkController()
    }

    func presentInterlinkController() {
        let interlinkViewController = InterlinkViewController()
        interlinkViewController.attachWithAnimation(to: parentViewController, below: parentOverlayView)
        presentedViewController = interlinkViewController

        SPTracker.trackEditorInterlinkAutocompleteViewed()
    }

    func relocateInterlinkController(around range: Range<String.Index>) {
        let keywordFrame = parentTextView.locationInWindowForText(in: range)
        let editingFrame = parentTextView.editingRectInWindow()

        presentedViewController?.relocateInterface(around: keywordFrame, in: editingFrame)
    }

    func trackLastKnownScrollOffsets() {
        lastKnownEditorOffset = parentTextView.contentOffset
        initialEditorOffset = parentTextView.contentOffset
    }

    func refreshInterlinkController(notes: [Note]) {
        presentedViewController?.notes = notes
    }

    func setupInterlinkEventListeners(replacementRange: Range<String.Index>) {
        presentedViewController?.onInsertInterlink = { [weak self] text in
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
        guard let interlinkViewController = presentedViewController else {
            return
        }

        defer {
            lastKnownEditorOffset = contentOffset
        }

        guard let oldY = lastKnownEditorOffset?.y, let initialY = initialEditorOffset?.y else {
            return
        }

        interlinkViewController.relocateInterface(by: oldY - contentOffset.y)
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

    var isInterlinkLookupOnScreen: Bool {
        presentedViewController?.parent != nil
    }

    var mustProcessInterlinkLookup: Bool {
        let editor = parentTextView
        return editor.isFirstResponder && !editor.isTextSelected && !editor.isUndoingEditOP
    }

    var mustDismissInterlinkLookup: Bool {
        let editor = parentTextView
        return editor.isDragging || editor.isTextSelected || !editor.isFirstResponder || !editor.isEditingInterlink
    }
}


// MARK: - Delegate Wrappers
//
private extension InterlinkProcessor {

    var excludedEntityID: NSManagedObjectID? {
        delegate?.excludedEntityIdentifierForInterlinkProcessor(self)
    }

    var parentOverlayView: UIView {
        guard let parent = contextProvider?.parentOverlayViewForInterlinkProcessor(self) else {
            fatalError("☠️ InterlinkProcessor: Please set a valid contextProvider!")
        }

        return parent
    }

    var parentTextView: UITextView {
        guard let parent = contextProvider?.parentTextViewForInterlinkProcessor(self) else {
            fatalError("☠️ InterlinkProcessor: Please set a valid contextProvider!")
        }

        return parent
    }

    var parentViewController: UIViewController {
        guard let parent = contextProvider?.parentViewControllerForInterlinkProcessor(self) else {
            fatalError("☠️ InterlinkProcessor: Please set a valid contextProvider!")
        }

        return parent
    }
}


// MARK: - Settings
//
private enum Settings {
    static let maximumAllowedScrollOffset = CGFloat(20)
}
