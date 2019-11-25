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
        resultsController.keyword = keyword
        tableView.reloadData()
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
        guard resultsController.keyword.count > 0 else {
            return
        }

        updateSearchResults(keyword: String())
        tableView.scrollToTop(animated: false)
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
        // Refresh the Container's UI
        view.backgroundColor = .simplenoteBackgroundColor

        // Refresh the Table's UI
        tableView.applySimplenotePlainStyle()
        tableView.reloadData()
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

        let note = resultsController.object(at: indexPath)
        if note.preview == nil {
            note.createPreview()
        }

        cell.titleText = note.titlePreview
        cell.bodyText = note.bodyPreview

        return cell
    }
}
