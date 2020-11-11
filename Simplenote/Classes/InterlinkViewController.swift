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
    @IBOutlet private var tableTopConstraint: NSLayoutConstraint!
    @IBOutlet private var tableHeightConstraint: NSLayoutConstraint!

    /// KVO
    ///
    private var kvoOffsetToken: NSKeyValueObservation?

    /// Interlink Notes to be presented onScreen
    ///
    var notes = [Note]() {
        didSet {
            tableView?.reloadData()
        }
    }


    // MARK: - Overridden API(s)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRootView()
        setupBackgroundView()
        setupTableView()
        setupShadowLayer()
    }
}


// MARK: - Public API(s)
//
extension InterlinkViewController {

    /// Relocates the receiver so that it shows up around a given Keyword in a **Sibling TextView**
    /// - Important: We'll start listening for Content Offset changes, and the UI will be automatically repositioned
    ///
    func anchorView(around keywordRange: Range<String.Index>, in siblingTextView: UITextView) {
        refreshConstraints(keywordRange: keywordRange, in: siblingTextView)
        startObservingContentOffset(in: siblingTextView)
    }
}


// MARK: - Initialization
//
private extension InterlinkViewController {

    func setupRootView() {
        view.frame = UIScreen.main.bounds
        view.backgroundColor = .clear
    }

    func setupBackgroundView() {
        backgroundView.backgroundColor = .simplenoteAutocompleteBackgroundColor
    }

    func setupShadowLayer() {
        let backgroundLayer = backgroundView.layer
        backgroundLayer.cornerRadius = Metrics.cornerRadius
        backgroundLayer.shadowRadius = Shadow.radius
        backgroundLayer.shadowOpacity = Shadow.opacity
        backgroundLayer.shadowOffset = Shadow.offset
    }

    func setupTableView() {
        tableView.register(Value1TableViewCell.self, forCellReuseIdentifier: Value1TableViewCell.reuseIdentifier)
        tableView.backgroundColor = .clear
        tableView.separatorColor = .simplenoteDividerColor
        tableView.tableFooterView = UIView()
        tableView.layer.cornerRadius = Metrics.cornerRadius
    }
}


// MARK: - UITableViewDataSource
//
extension InterlinkViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let note = notes[indexPath.row]
        note.ensurePreviewStringsAreAvailable()

        let tableViewCell = tableView.dequeueReusableCell(ofType: Value1TableViewCell.self, for: indexPath)
        tableViewCell.title = note.titlePreview
        tableViewCell.backgroundColor = .clear
        tableViewCell.separatorInset = .zero

        return tableViewCell
    }
}


// MARK: - Geometry
//
private extension InterlinkViewController {

    /// Updates the layout constraints so that the receiver shows up **around** the specified Keyword in the specified TextView
    ///
    func refreshConstraints(keywordRange: Range<String.Index>, in textView: UITextView) {
        let targetHeight = calculateHeight()
        let targetLocation = calculateLocation(for: targetHeight, around: keywordRange, in: textView)
        let targetPadding = textView.textContainer.lineFragmentPadding

        tableTopConstraint.constant = targetLocation
        tableHeightConstraint.constant = targetHeight
        tableLeadingConstraint.constant = targetPadding
        tableTrailingConstraint.constant = targetPadding
    }

    /// Starts tracking ContentOffset changes in our sibling TextView
    ///
    func startObservingContentOffset(in textView: UITextView) {
        kvoOffsetToken = textView.observe(\UITextView.contentOffset, options: [.old, .new]) { [weak self] (_, value) in
            guard let oldY = value.oldValue?.y, let newY = value.newValue?.y, oldY != newY else {
                return
            }

            self?.tableTopConstraint.constant += oldY - newY
        }
    }

    /// Returns the target Origin.Y
    /// -   Parameters:
    ///     - height: The new target height
    ///     - range: Anchor's Range
    ///     - textView: Sibling TextView
    ///
    /// - Important: We'll always prefer either the "location above the cursor" whenever the **Maxed Out TableView** can be fit (that is: +3.5 results!)
    ///
    func calculateLocation(for height: CGFloat, around range: Range<String.Index>, in textView: UITextView) -> CGFloat {
        let anchorFrame = textView.locationInSuperviewForText(in: range)
        let minimumLocationForFullHeight = anchorFrame.minY - Metrics.resultsPadding - Metrics.maximumTableHeight

        if minimumLocationForFullHeight > textView.editingRect().minY {
            return anchorFrame.minY - Metrics.resultsPadding - height
        }

        return anchorFrame.maxY + Metrics.resultsPadding
    }

    /// Returns the target Size.Height
    ///
    func calculateHeight() -> CGFloat {
        let fullHeight = CGFloat(notes.count) * Metrics.defaultCellHeight
        return min(fullHeight, Metrics.maximumTableHeight)
    }
}


// MARK: - Metrics
//
private enum Metrics {
    static let cornerRadius = CGFloat(10)
    static let defaultCellHeight = CGFloat(44)
    static let maximumVisibleCells = 3.5
    static let maximumTableHeight = defaultCellHeight * CGFloat(maximumVisibleCells)
    static let resultsPadding = CGFloat(12)
}

private enum Shadow {
    static let opacity = Float(0.2)
    static let offset = CGSize(width: 0, height: 32)
    static let radius = CGFloat(64)
}
