import Foundation
import UIKit


// MARK: - SPSearchResultsViewController
//
class SPSearchResultsViewController: UIViewController {

    /// Results TableView
    ///
    @IBOutlet private weak var tableView: UITableView!

    private var mainContext: NSManagedObjectContext {
        SPAppDelegate.shared().managedObjectContext
    }

    /// Results DataSource
    ///
    private lazy var resultsController: SPSearchResultsController = {
        SPSearchResultsController(mainContext: mainContext)
    }()


    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureResultsController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshStyle()
        refreshRowHeight()
        reset()
    }
}


// MARK: - Interface Initialization
//
extension SPSearchResultsViewController {

    /// Updates the Search Results to match a given keyword
    ///
    @objc
    func updateSearchResults(keyword: String) {
        // Note: Async, otherwise the UI won't feel snappy!
        DispatchQueue.main.async {
            self.resultsController.keyword = keyword
            self.tableView.reloadData()
        }
    }
}


// MARK: - Private Helpers
//
private extension SPSearchResultsViewController {

    func configureResultsController() {
        try? resultsController.performFetch()
        tableView.reloadData()
    }

    func reset() {
        updateSearchResults(keyword: String())
    }
}


// MARK: - Interface Initialization
//
private extension SPSearchResultsViewController {

    /// Sets up the TableView
    ///
    func configureTableView() {
        tableView.register(SPNoteTableViewCell.loadNib(), forCellReuseIdentifier: SPNoteTableViewCell.reuseIdentifier)
        tableView.tableFooterView = UIView()
    }

    /// Refreshes the UI Style (iOS <13 DarkMode Support)
    ///
    func refreshStyle() {
        view.backgroundColor = .simplenoteBackgroundColor
        tableView.applySimplenotePlainStyle()
    }

    /// Recalculates the TableView's Row Height
    ///
    func refreshRowHeight() {
        tableView.rowHeight = SPNoteTableViewCell.cellHeight
    }
}


// MARK: - UITableViewDataSource Methods
//
extension SPSearchResultsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        resultsController.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        resultsController.sections[section].numberOfObjects
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SPNoteTableViewCell.reuseIdentifier, for: indexPath) as? SPNoteTableViewCell else {
            fatalError()
        }

        configure(cell: cell, at: indexPath)

        return cell
    }
}


// MARK: - Private Methods
//
private extension SPSearchResultsViewController {

    /// Sets up a given NoteTableViewCell to display the specified Note
    ///
    func configure(cell: SPNoteTableViewCell, at indexPath: IndexPath) {
        let note = resultsController.object(at: indexPath)

        if note.preview == nil {
            note.createPreview()
        }

        cell.accessibilityLabel = note.titlePreview
        cell.accessibilityHint = NSLocalizedString("Open note", comment: "Select a note to view in the note editor")

        cell.accessoryLeftImage = note.published ? .image(name: .shared) : nil
        cell.accessoryRightImage = note.pinned ? .image(name: .pin) : nil
        cell.accessoryLeftTintColor = .simplenoteNoteStatusImageColor
        cell.accessoryRightTintColor = .simplenoteNoteStatusImageColor

        cell.rendersInCondensedMode = Options.shared.condensedNotesList
        cell.titleText = note.titlePreview
        cell.bodyText = note.bodyPreview

        guard resultsController.keyword.count > 0 else {
            return
        }

        cell.highlightSubstrings(matching: resultsController.keyword, color: .simplenoteTintColor)
    }
}
