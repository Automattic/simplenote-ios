import Foundation
import UIKit


// MARK: - InterlinkViewController
//
class InterlinkViewController: UIViewController {

    /// Autocomplete TableView
    ///
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var backgroundView: UIVisualEffectView!
    @IBOutlet private var shadowView: SPShadowView!

    /// Layout Constraints: Inner TableView
    ///
    @IBOutlet private var tableLeftConstraint: NSLayoutConstraint!
    @IBOutlet private var tableTopConstraint: NSLayoutConstraint!
    @IBOutlet private var tableHeightConstraint: NSLayoutConstraint!

    /// Closure to be executed whenever a Note is selected. The Interlink URL will be passed along.
    ///
    var onInsertInterlink: ((String) -> Void)?

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
        setupShadowView()
    }
}


// MARK: - Public API(s)
//
extension InterlinkViewController {

    /// Relocates the receiver so that it shows up **around** the specified Anchor Frame, in a given ViewPort.
    /// - Important: Both frames must be expressed in Window Coordinates. Capisce?
    ///
    func relocateInterface(around anchor: CGRect, in viewport: CGRect) {
        let anchorFrame = view.convert(anchor, from: nil)
        let editingRect = view.convert(viewport, from: nil)

        let targetHeight = calculateHeight()
        let targetTop = calculateTopLocation(for: targetHeight, around: anchorFrame, in: editingRect)
        let targetLeft = calculateLeftLocation(around: anchorFrame, in: editingRect)

        tableTopConstraint.constant = targetTop
        tableHeightConstraint.constant = targetHeight
        tableLeftConstraint.constant = targetLeft
    }

    /// Adjusts the Interlink TableView by the specified offset
    ///
    func relocateInterface(by deltaY: CGFloat) {
        tableTopConstraint.constant += deltaY
    }
}


// MARK: - Initialization
//
private extension InterlinkViewController {

    func setupRootView() {
        view.backgroundColor = .clear
    }

    func setupBackgroundView() {
        backgroundView.backgroundColor = .simplenoteAutocompleteBackgroundColor
        backgroundView.layer.cornerRadius = Metrics.cornerRadius
        backgroundView.layer.masksToBounds = true
    }

    func setupTableView() {
        tableView.register(Value1TableViewCell.self, forCellReuseIdentifier: Value1TableViewCell.reuseIdentifier)
        tableView.backgroundColor = .clear
        tableView.separatorColor = .simplenoteDividerColor
        tableView.tableFooterView = UIView()
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = Metrics.cornerRadius
    }

    func setupShadowView() {
        shadowView.cornerRadius = Metrics.cornerRadius
    }
}


// MARK: - UITableViewDataSource
//
extension InterlinkViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // "Drops" the last separator!
        .leastNonzeroMagnitude
    }

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


// MARK: - UITableViewDelegate
//
extension InterlinkViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = notes[indexPath.row]
        performInterlinkInsert(for: note)
    }
}


// MARK: - Geometry
//
private extension InterlinkViewController {

    /// Returns the Target Origin.Y
    ///
    /// -   Parameters:
    ///     - height: The new target height
    ///     - anchor: Frame around which we should position the TableView
    ///     - viewport: Editor's visible frame
    ///
    /// -   Important: We'll always prefer the orientation that results in the **Least Clipped Surface™**
    ///
    func calculateTopLocation(for height: CGFloat, around anchor: CGRect, in viewport: CGRect) -> CGFloat {
        let minimumLocationForFullHeight = anchor.minY - Metrics.defaultTableInsets.top - Metrics.maximumTableHeight
        let locationAbove = anchor.minY - Metrics.defaultTableInsets.top - height
        let locationBelow = anchor.maxY + Metrics.defaultTableInsets.top

        let deltaAbove = minimumLocationForFullHeight - viewport.minY
        let deltaBelow = viewport.maxY - locationBelow - height
        let dispayingAboveClips = deltaAbove < .zero
        let dispayingBelowClips = deltaBelow < .zero

        if dispayingAboveClips == false && dispayingBelowClips == false ||
            dispayingAboveClips == false && deltaAbove > deltaBelow ||
            dispayingAboveClips && dispayingBelowClips && deltaAbove > deltaBelow
        {
            return locationAbove
        }

        return locationBelow
    }

    /// Returns the Target Origin.X
    ///
    /// -   Parameters:
    ///     - anchor: Frame around which we should position the TableView
    ///     - viewport: Editor's visible frame
    ///
    /// -   Note: We'll align the Table **Text**, horizontally, with regards of the anchor frame. That's why we consider layout margins!
    /// -   Important: Whenever we overflow horizontally, we'll simply ensure there's enough breathing room on the right hand side
    ///
    func calculateLeftLocation(around anchor: CGRect, in viewport: CGRect) -> CGFloat {
        let maximumX = anchor.minX + Metrics.defaultTableWidth + tableView.layoutMargins.right
        if viewport.width > maximumX {
            return anchor.minX - tableView.layoutMargins.left
        }

        return anchor.minX + viewport.width - maximumX
    }


    /// Returns the target Size.Height
    ///
    func calculateHeight() -> CGFloat {
        let fullHeight = CGFloat(notes.count) * Metrics.defaultCellHeight
        return min(fullHeight, Metrics.maximumTableHeight)
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
}


// MARK: - Metrics
//
private enum Metrics {
    static let cornerRadius = CGFloat(10)
    static let defaultCellHeight = CGFloat(44)
    static let defaultTableInsets = UIEdgeInsets(top: 12, left: 20, bottom: 0, right: 20)
    static let defaultTableWidth = CGFloat(300)
    static let maximumVisibleCells = 3.5
    static let maximumTableHeight = defaultCellHeight * CGFloat(maximumVisibleCells)
}
