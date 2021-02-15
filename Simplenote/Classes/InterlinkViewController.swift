import Foundation
import UIKit


// MARK: - InterlinkViewController
//
class InterlinkViewController: UIViewController {

    /// Autocomplete TableView
    ///
    @IBOutlet private var tableView: HuggableTableView!

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

    var desiredHeight: CGFloat {
        return Metrics.maximumTableHeight
    }
    
    // MARK: - Overridden API(s)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRootView()
        setupTableView()
    }
}


// MARK: - Initialization
//
private extension InterlinkViewController {

    func setupRootView() {
        view.backgroundColor = .clear
    }

    func setupTableView() {
        tableView.register(Value1TableViewCell.self, forCellReuseIdentifier: Value1TableViewCell.reuseIdentifier)
        tableView.backgroundColor = .clear
        tableView.separatorColor = .simplenoteDividerColor
        tableView.tableFooterView = UIView()
        tableView.alwaysBounceVertical = false

        tableView.minHeightConstraint.constant = Metrics.minimumTableHeight
        tableView.maxHeightConstraint.constant = Metrics.maximumTableHeight
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
    static let defaultCellHeight = CGFloat(44)

    static let maximumVisibleCells = 3.5
    static let maximumTableHeight = defaultCellHeight * CGFloat(maximumVisibleCells)
    static let minimumTableHeight = defaultCellHeight
}
