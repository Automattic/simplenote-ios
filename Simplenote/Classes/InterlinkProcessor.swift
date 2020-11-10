import Foundation



// MARK: - InterlinkPresentationContextProvider
//
protocol InterlinkProcessorPresentationContextProvider: NSObjectProtocol {
    func parentTextViewForInterlinkProcessor(_ processor: InterlinkProcessor) -> UITextView
    func parentViewControllerForInterlinkProcessor(_ processor: InterlinkProcessor) -> UIViewController
}


// MARK: - InterlinkProcessorDelegate
//
protocol InterlinkProcessorDelegate: NSObjectProtocol {
    func interlinkProcessor(_ processor: InterlinkProcessor, insert text: String, in range: Range<String.Index>)
}

// MARK: - InterlinkProcessorDatasource
//
protocol InterlinkProcessorDatasource: NSObjectProtocol {
    var interlinkExcudedEntityID: NSManagedObjectID? { get }
    var interlinkViewContext: NSManagedObjectContext { get }
}


// MARK: - InterlinkProcessor
//
class InterlinkProcessor: NSObject {

    private var presentedViewController: InterlinkViewController?
    private lazy var resultsController = InterlinkResultsController(viewContext: viewContext)

    weak var contextProvider: InterlinkProcessorPresentationContextProvider?
    weak var delegate: InterlinkProcessorDelegate?
    weak var datasource: InterlinkProcessorDatasource?


    /// Displays the Interlink Lookup Window at the cursor's location when all of the following are **true**:
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
            dismissInterlinkController()
            return
        }

        ensureInterlinkControllerIsOnScreen()
        relocateInterlinkController(around: keywordRange)
        refreshInterlinkController(notes: notes, range: markdownRange)
    }

    /// Dismisses the Interlink Window when ANY of the following evaluates **true**:
    ///
    ///     1.  There is Highlighted Text in the editor (or)
    ///     2.  There is no Interlink `[keyword` at the selected location
    ///
    @objc
    func dismissInterlinkLookupIfNeeded() {
        guard mustDismissInterlinkLookup else {
            return
        }

        dismissInterlinkController()
    }
}


// MARK: - Presenting
//
extension InterlinkProcessor {

    func ensureInterlinkControllerIsOnScreen() {
        if let _ = presentedViewController {
            return
        }

        presentInterlinkController()
    }

    func relocateInterlinkController(around range: Range<String.Index>) {
        presentedViewController?.anchorView(around: range, in: parentTextView)
    }

    func refreshInterlinkController(notes: [Note], range: Range<String.Index>) {
        presentedViewController?.notes = notes
        presentedViewController?.onInsertInterlink = { [weak self] text in
            self?.notifyInsertText(text: text, in: range)
            self?.dismissInterlinkController()
        }
    }

    func notifyInsertText(text: String, in range: Range<String.Index>) {
        delegate?.interlinkProcessor(self, insert: text, in: range)
    }

    func presentInterlinkController() {
        let interlinkViewController = InterlinkViewController()
        interlinkViewController.attachWithAnimation(to: parentViewController)
        self.presentedViewController = interlinkViewController
    }

    func dismissInterlinkController() {
        presentedViewController?.detachWithAnimation()
        presentedViewController = nil
    }
}


// MARK: - State
//
private extension InterlinkProcessor {

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
        datasource?.interlinkExcudedEntityID
    }

    var viewContext: NSManagedObjectContext {
        guard let context = datasource?.interlinkViewContext else {
            fatalError("☠️ InterlinkProcessor: Please set a valid datasource!")
        }

        return context
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
