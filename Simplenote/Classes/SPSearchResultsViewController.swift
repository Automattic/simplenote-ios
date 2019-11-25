import Foundation
import UIKit


// MARK: - SPSearchResultsViewController
//
class SPSearchResultsViewController: UIViewController {

    /// Results TableView
    ///
    @IBOutlet private weak var tableView: UITableView!

    /// Results DataSource
    ///
    private let resultsDataSource: SPSearchResultsDataSource = {
        SPSearchResultsDataSource(mainContext: SPAppDelegate.shared().managedObjectContext)
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
    }
}


// MARK: - Interface Initialization
//
extension SPSearchResultsViewController {

    /// Updates the Search Results to match a given keyword
    ///
    @objc
    func updateSearchResults(keyword: String) {
        resultsDataSource.keyword = keyword

// TODO: FRC Sync
        tableView.reloadData()
    }
}


// MARK: - Private Helpers
//
private extension SPSearchResultsViewController {

    func configureResultsController() {
        try? resultsDataSource.performFetch()
        tableView.reloadData()
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
        resultsDataSource.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        resultsDataSource.sections[section].numberOfObjects
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SPNoteTableViewCell.reuseIdentifier, for: indexPath) as? SPNoteTableViewCell else {
            fatalError()
        }

        let note = resultsDataSource.object(at: indexPath)
        if note.preview == nil {
            note.createPreview()
        }

        cell.titleText = note.titlePreview
        cell.bodyText = note.bodyPreview

        return cell
    }
}
