import Foundation
import UIKit
import SimplenoteFoundation


// MARK: - InterlinkViewController
//
class InterlinkViewController: UIViewController {

    /// Autocomplete TableView
    ///
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var backgroundView: UIVisualEffectView!

    /// Layout Constraints: Inner TableView
    ///
    @IBOutlet private var tableLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private var tableTrailingConstraint: NSLayoutConstraint!

    /// Layout Constraints: Container
    ///
    private weak var topConstraint: NSLayoutConstraint?
    private weak var heightConstraint: NSLayoutConstraint?

    /// KVO
    ///
    private var kvoOffsetToken: NSKeyValueObservation?

    /// Main Context
    ///
    private var mainContext: NSManagedObjectContext {
        SPAppDelegate.shared().managedObjectContext
    }

    /// ResultsController: In charge of CoreData Queries!
    ///
    private lazy var resultsController: ResultsController<Note> = {
        return ResultsController<Note>(viewContext: mainContext, sortedBy: [
            NSSortDescriptor(keyPath: \Note.content, ascending: true)
        ])
    }()


    /// In-Memory Filtered Notes
    /// -   Our Storage does not split `Title / Body`. Filtering by keywords in the title require a NSPredicate + Block
    /// -   The above is awfully underperformant.
    /// -   Most efficient approach code wise / speed involves simply keeping a FRC instance, and filtering it as needed
    ///
    private var filteredNotes = [Note]()

    /// Closure to be executed whenever a Note is selected. The Interlink URL will be passed along.
    ///
    var onInsertInterlink: ((String) -> Void)?



    // MARK: - Overridden API(s)

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupResultsController()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRootView()
        setupBackgroundView()
        setupTableView()
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        guard let superview = parent?.view else {
            return
        }

        setupConstraints(superview: superview)
    }
}


// MARK: - Initialization
//
private extension InterlinkViewController {

    func setupRootView() {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
    }

    func setupConstraints(superview: UIView) {
        let topConstraint = view.topAnchor.constraint(equalTo: superview.topAnchor)
        let heightConstraint = view.heightAnchor.constraint(equalToConstant: Metrics.defaultHeight)

        NSLayoutConstraint.activate([
            view.leftAnchor.constraint(equalTo: superview.leftAnchor),
            view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            topConstraint,
            heightConstraint
        ])

        self.topConstraint = topConstraint
        self.heightConstraint = heightConstraint
    }

    func setupResultsController() {
        resultsController.predicate = NSPredicate.predicateForNotes(deleted: false)
        try? resultsController.performFetch()
    }

    func setupBackgroundView() {
        backgroundView.layer.cornerRadius = Metrics.cornerRadius
        backgroundView.backgroundColor = .simplenoteAutocompleteBackgroundColor
    }

    func setupTableView() {
        tableView.register(Value1TableViewCell.self, forCellReuseIdentifier: Value1TableViewCell.reuseIdentifier)
        tableView.layoutMargins = .zero
        tableView.backgroundColor = .clear
        tableView.separatorColor = .simplenoteDividerColor

        //  Fix: Hide the cellSeparators, when the table is empty
        tableView.tableFooterView = UIView()
    }
}


// MARK: - Public API(s)
//
extension InterlinkViewController {

    /// Relocates the receiver so that it shows up around a given Keyword in a TextView.
    /// - Important: We'll start listening for Content Offset changes, and the UI will be automatically repositioned
    ///
    func anchorView(around keywordRange: Range<String.Index>, in textView: UITextView) {
        refreshConstraints(keywordRange: keywordRange, in: textView)
        refreshInnerPadding(for: textView)

        kvoOffsetToken = textView.observe(\UITextView.contentOffset, options: [.old, .new]) { [weak self] (textView, value) in
            guard let topConstraint = self?.topConstraint,
                  let oldOffsetY = value.oldValue?.y,
                  let newOffsetY = value.newValue?.y,
                  oldOffsetY != newOffsetY
            else {
                return
            }

            topConstraint.constant += oldOffsetY - newOffsetY
        }
    }

    /// Refreshes the Autocomplete Results. Returns `true` when there are visible rows.
    /// - Important:
    ///     By design, whenever there are no results we won't be refreshing the TableView. Instead, we'll stick to the "old results".
    ///     This way we get to avoid the awkward visual effect of "empty autocomplete view"
    ///
    func refreshInterlinks(for keyword: String, excluding excludedID: NSManagedObjectID?) -> Bool {
        filteredNotes = filterNotes(resultsController.fetchedObjects, byTitleKeyword: keyword, excluding: excludedID)
        let displaysRows = filteredNotes.count > .zero

        if displaysRows {
            refreshTableViewIfNeeded()
        }

        return displaysRows
    }
}


// MARK: - Filtering
//
private extension InterlinkViewController {

    /// Filters a collection of notes by their Title contents, excluding a specific Object ID.
    ///
    /// - Important: Why do we perform an *in memory* filtering?
    ///     - CoreData's SQLite store does not support block based predicates
    ///     - RegExes aren't diacritic + case insensitve friendly
    ///     - It's easier and anyone can follow along!
    ///
    func filterNotes(_ notes: [Note], byTitleKeyword keyword: String, excluding excludedID: NSManagedObjectID?, limit: Int = Settings.maximumNumberOfResults) -> [Note] {
        var output = [Note]()
        let normalizedKeyword = keyword.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)

        for note in notes where note.objectID != excludedID {
            note.ensurePreviewStringsAreAvailable()
            guard let normalizedTitle = note.titlePreview?.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil),
                  normalizedTitle.contains(normalizedKeyword)
            else {
                continue
            }

            output.append(note)

            if output.count >= limit {
                break
            }
        }

        return output
    }
}


// MARK: - Private API(s)
//
private extension InterlinkViewController {

    func noteAtIndexPath(_ indexPath: IndexPath) -> Note {
        filteredNotes[indexPath.row]
    }

    func performInterlinkInsert(for note: Note) {
        guard let markdownInterlink = note.markdownInternalLink else {
            return
        }

        onInsertInterlink?(markdownInterlink)
    }

    func refreshTableViewIfNeeded() {
        guard isViewLoaded else {
            return
        }

        tableView.reloadData()
    }
}


// MARK: - UITableViewDataSource
//
extension InterlinkViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredNotes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let note = noteAtIndexPath(indexPath)
        note.ensurePreviewStringsAreAvailable()

        let tableViewCell = tableView.dequeueReusableCell(ofType: Value1TableViewCell.self, for: indexPath)
        tableViewCell.title = note.titlePreview
        tableViewCell.backgroundColor = .clear

        return tableViewCell
    }
}


// MARK: - UITableViewDelegate
//
extension InterlinkViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = noteAtIndexPath(indexPath)
        performInterlinkInsert(for: note)
    }
}


// MARK: - Geometry
//
private extension InterlinkViewController {

    /// Updates the layout constraints so that the receiver shows up **around** the specified Keyword in a given TextView
    ///
    func refreshConstraints(keywordRange: Range<String.Index>, in textView: UITextView) {
        let targetHeight = calculateHeight()
        let targetLocation = calculateLocation(for: targetHeight, around: keywordRange, in: textView)

        topConstraint?.constant = targetLocation
        heightConstraint?.constant = targetHeight
    }

    /// Updates the inner TableView's leading / trailing padding
    ///
    func refreshInnerPadding(for textView: UITextView) {
        let padding = textView.textContainer.lineFragmentPadding
        tableLeadingConstraint.constant = padding
        tableTrailingConstraint.constant = padding
    }

    /// Returns the target Origin.Y
    ///
    func calculateLocation(for height: CGFloat, around range: Range<String.Index>, in textView: UITextView) -> CGFloat {
        let containerFrame = textView.editingRect()
        let anchor = textView.locationInSuperviewForText(in: range)
        let locationOnTop = anchor.minY - height

        return locationOnTop > containerFrame.minY ? locationOnTop : anchor.maxY
    }

    /// Returns the target Height
    ///
    func calculateHeight() -> CGFloat {
// TODO: Depends on the actual results onscreen
        Metrics.defaultHeight
    }
}


// MARK: - Metrics
//
private enum Metrics {
    static let cornerRadius = CGFloat(10)
    static let defaultHeight = CGFloat(154)
}


// MARK: - Settings!
//
private enum Settings {
    static let maximumNumberOfResults = 15
}
