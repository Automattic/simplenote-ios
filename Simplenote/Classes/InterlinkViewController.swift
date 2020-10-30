import Foundation
import UIKit


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

    /// ResultsController
    ///
    private let controller = InterlinkResultsController()

    /// Closure to be executed whenever a Note is selected. The Interlink URL will be passed along.
    ///
    var onInsertInterlink: ((String) -> Void)?



    // MARK: - Overridden API(s)

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


// MARK: - Public API(s)
//
extension InterlinkViewController {

    /// Relocates the receiver so that it shows up around a given Keyword in a TextView.
    /// - Important: We'll start listening for Content Offset changes, and the UI will be automatically repositioned
    ///
    func anchorView(around keywordRange: Range<String.Index>, in textView: UITextView) {
        refreshConstraints(keywordRange: keywordRange, in: textView)
        refreshInnerPadding(for: textView)
        startObservingContentOffset(in: textView)
    }

    /// Refreshes the Autocomplete Results. Returns `true` when there are visible rows.
    /// - Important:
    ///     By design, whenever there are no results we won't be refreshing the TableView. Instead, we'll stick to the "old results".
    ///     This way we get to avoid the awkward visual effect of "empty autocomplete view"
    ///
    func refreshInterlinks(for keyword: String, excluding excludedID: NSManagedObjectID?) -> Bool {
        guard controller.refreshInterlinks(for: keyword, excluding: excludedID) else {
            return false
        }

        refreshTableViewIfNeeded()
        return true
    }
}


// MARK: - Initialization
//
private extension InterlinkViewController {

    func setupRootView() {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
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
        tableView.tableFooterView = UIView()
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
}


// MARK: - UITableViewDataSource
//
extension InterlinkViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        controller.numberOfNotes
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let note = controller.note(at: indexPath.row)
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
        let note = controller.note(at: indexPath.row)
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

    /// Starts tracking ContentOffset changes in our sibling TextView
    ///
    func startObservingContentOffset(in textView: UITextView) {
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

    /// Returns the target Origin.Y
    ///
    func calculateLocation(for height: CGFloat, around range: Range<String.Index>, in textView: UITextView) -> CGFloat {
        let containerFrame = textView.editingRect()
        let anchor = textView.locationInSuperviewForText(in: range)
        let locationOnTop = anchor.minY - height

        return locationOnTop > containerFrame.minY ? locationOnTop : anchor.maxY
    }

    /// Returns the target Size.Height
    ///
    func calculateHeight() -> CGFloat {
// TODO: Depends on the actual results onscreen
        Metrics.defaultHeight
    }
}


// MARK: - Private API(s)
//
private extension InterlinkViewController {

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


// MARK: - Metrics
//
private enum Metrics {
    static let cornerRadius = CGFloat(10)
    static let defaultHeight = CGFloat(154)
}
