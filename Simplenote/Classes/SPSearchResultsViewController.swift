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
    }
}


// MARK: - Interface Initialization
//
extension SPSearchResultsViewController {

    /// Resets the internal state for reuse:
    ///     - Search Keyword will be neutralized
    ///     - TableView's Scroll position will be moved to the top
    ///
    @objc
    func reset() {
        tableView.scrollToTop(animated: false)
        updateSearchResults(keyword: String())
    }

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


// MARK: - Initialization Helpers
//
private extension SPSearchResultsViewController {

    func configureResultsController() {
        try? resultsController.performFetch()
        tableView.reloadData()
    }

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


// MARK: - UITableViewDelegate Methods
//
extension SPSearchResultsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presentEditor(note: note(at: indexPath), keyword: resultsController.keyword)

        SPTracker.trackListNoteOpened()
    }
}


// MARK: - Private Methods
//
private extension SPSearchResultsViewController {

    /// Sets up a given NoteTableViewCell to display the specified Note
    ///
    func configure(cell: SPNoteTableViewCell, at indexPath: IndexPath) {
        let note = self.note(at: indexPath)

        note.ensurePreviewStringsAreAvailable()

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

    /// Returns the Note at a given IndexPath
    ///
    func note(at indexPath: IndexPath) -> Note {
        resultsController.object(at: indexPath)
    }

    func presentEditor(note: Note, keyword: String) {
        let editorViewController = SPNoteEditorViewController()
        editorViewController.update(note)
        editorViewController.searchString = keyword

        /// We're sharing the navigationController with our container VC (expected to be NoteListViewController). Let's disable any custom anymations!
        navigationController?.delegate = nil
        navigationController?.pushViewController(editorViewController, animated: true)
    }
}
