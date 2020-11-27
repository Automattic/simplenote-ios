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
    func relocateInterface(around anchorInWindow: CGRect, in viewportInWindow: CGRect) {
        let anchor                          = view.convert(anchorInWindow, from: nil)
        let viewport                        = view.convert(viewportInWindow, from: nil)

        let (orientation, viewportSlice)    = calculateViewportSlice(around: anchor, in: viewport)
        let height                          = calculateHeight(viewport: viewportSlice)
        let topLocation                     = calculateTopLocation(for: height, around: anchor, orientation: orientation)
        let leftLocation                    = calculateLeftLocation(around: anchor, in: viewport)

        tableTopConstraint.constant         = topLocation
        tableHeightConstraint.constant      = height
        tableLeftConstraint.constant        = leftLocation
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

    /// We'll always prefer displaying the Autocomplete UI **above** the cursor, whenever such location does not produce clipping.
    /// Even if there's more room at the bottom (that's why a simple max calculation isn't enough!)
    ///
    /// - Important: In order to avoid flipping Up / Down, we'll consider the Maximum Heigh tour TableView can acquire
    ///
    func calculateViewportSlice(around anchor: CGRect, in viewport: CGRect) -> (Orientation, CGRect) {
        /// Nosebleed: In iOS the (0, 0) is top left. For that reason we're inverting the Above / Below subframes.
        ///
        let (viewportBelow, viewportAbove)  = viewport.split(by: anchor)
        let deltaAbove                      = viewportAbove.height - Metrics.maximumTableHeight
        let deltaBelow                      = viewportBelow.height - Metrics.maximumTableHeight

        if (deltaAbove >= .zero) || (deltaAbove < .zero && deltaBelow < .zero && deltaAbove > deltaBelow) {
            return (.above, viewportAbove)
        }

        return (.below, viewportBelow)
    }

    /// Returns the target Size.Height for the specified viewport metrics
    ///
    func calculateHeight(viewport: CGRect) -> CGFloat {
        let requiredHeight          = CGFloat(notes.count) * Metrics.defaultCellHeight
        let availableHeight         = viewport.height - Metrics.defaultTableInsets.top - Metrics.defaultTableInsets.bottom
        let cappedAvailableHeight   = min(availableHeight, Metrics.maximumTableHeight)

        return max(min(requiredHeight, cappedAvailableHeight), Metrics.minimumTableHeight)
    }

    /// Returns the Target Origin.Y
    ///
    /// -   Parameters:
    ///     - height: The new target height
    ///     - anchor: Frame around which we should position the TableView
    ///     - orientation: Defines the orientation in which we'll render out Autocomplete UI
    ///
    /// -   Important: We'll always prefer the orientation that results in the **Least Clipped Surface™**
    ///
    func calculateTopLocation(for height: CGFloat, around anchor: CGRect, orientation: Orientation) -> CGFloat {
        switch orientation {
        case .above:
            return anchor.minY - Metrics.defaultTableInsets.top - height
        case .below:
            return anchor.maxY + Metrics.defaultTableInsets.top
        }
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


// MARK: - Defines the vertical orientation in which we'll display our Autocomplete UI
//
private enum Orientation {
    case above
    case below
}


// MARK: - Metrics
//
private enum Metrics {
    static let cornerRadius = CGFloat(10)
    static let defaultCellHeight = CGFloat(44)
    static let defaultTableInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
    static let defaultTableWidth = CGFloat(300)
    static let maximumVisibleCells = 3.5
    static let maximumTableHeight = defaultCellHeight * CGFloat(maximumVisibleCells)
    static let minimumTableHeight = defaultCellHeight
}
