import Foundation
import UIKit


// MARK: - SPSearchResultsViewController
//
class SPSearchResultsViewController: UIViewController {

    /// Results TableView
    ///
    @IBOutlet private weak var tableView: UITableView!


    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
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
    // TODO: Wire Me!
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

    // TODO: Demo code. Replace with the actual CoreData fetch!

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SPNoteTableViewCell.reuseIdentifier, for: indexPath) as? SPNoteTableViewCell else {
            fatalError()
        }

        cell.titleText = "Some Title"
        cell.bodyText = "Body Here!"

        return cell
    }
}
