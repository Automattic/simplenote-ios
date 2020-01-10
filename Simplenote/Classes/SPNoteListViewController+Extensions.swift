import Foundation
import UIKit


// MARK: - Components Initialization
//
extension SPNoteListViewController {

    /// Sets up the Results Controller
    ///
    @objc
    func configureResultsController() {
        assert(resultsController == nil, "resultsController is already initialized!")

        let viewContext = SPAppDelegate.shared().simperium.managedObjectContext()!
        resultsController = SPSearchResultsController(viewContext: viewContext)
        try? resultsController.performFetch()
    }
}


// MARK: - Interface Initialization
//
extension SPNoteListViewController {

    /// Sets up the Root ViewController
    ///
    @objc
    func configureRootView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        navigationBarBackground.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        view.addSubview(navigationBarBackground)
        view.addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.searchBarInsets.left),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Constants.searchBarInsets.right)
        ])

        NSLayoutConstraint.activate([
            navigationBarBackground.topAnchor.constraint(equalTo: view.topAnchor),
            navigationBarBackground.leftAnchor.constraint(equalTo: view.leftAnchor),
            navigationBarBackground.rightAnchor.constraint(equalTo: view.rightAnchor),
            navigationBarBackground.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    /// Adjust the TableView's Insets, so that the content falls below the searchBar
    ///
    @objc
    func refreshTableViewInsets() {
        tableView.contentInset.top = searchBar.frame.height
        tableView.scrollIndicatorInsets.top = searchBar.frame.height
    }

    /// Workaround: Scroll to the very first row. Expected to be called *just* once, right after the view has been laid out, and has been moved
    /// to its parent ViewController.
    ///
    /// Ref. Issue #452
    ///
    @objc
    func ensureFirstRowIsVisible() {
        guard !tableView.isHidden else {
            return
        }

        tableView.contentOffset.y = tableView.adjustedContentInset.top * -1
    }
}


// MARK: - Internal Methods
//
extension SPNoteListViewController {

    /// Registers the ListViewController for Peek and Pop events.
    ///
    @objc
    func registerForPeekAndPop() {
        registerForPreviewing(with: self, sourceView: tableView)
    }

    /// Refreshes the ListViewController's Title
    ///
    @objc
    func refreshTitle() {
        let selectedTag = SPAppDelegate.shared().selectedTag ?? NSLocalizedString("All Notes", comment: "Title: No filters applied")

        switch selectedTag {
        case kSimplenoteTrashKey:
            title = NSLocalizedString("Trash-noun", comment: "Title: Trash Tag is selected")
        case kSimplenoteUntaggedKey:
            title = NSLocalizedString("Untagged", comment: "Title: Untagged Notes are onscreen")
        default:
            title = selectedTag
        }
    }

    /// Refreshes the ResultsController Filters
    ///
    @objc
    func refreshResultsController() {
        var selectedTag: String?
        switch SPAppDelegate.shared().selectedTag {
        case kSimplenoteTrashKey:
            tagFilterType = .deleted
        case kSimplenoteUntaggedKey:
            tagFilterType = .untagged
        case let tag:
            tagFilterType = .userTag
            selectedTag = tag
        }

        resultsController.filter = tagFilterType
        resultsController.selectedTag = selectedTag
        resultsController.keyword = searchText
        resultsController.sortMode = Options.shared.listSortMode
        try? resultsController.performFetch()

        tableView.reloadData()
    }
}


// MARK: - UIViewControllerPreviewingDelegate Conformance
//
extension SPNoteListViewController: UIViewControllerPreviewingDelegate {

    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard tableView.isUserInteractionEnabled,
            tagFilterType != .deleted,
            let indexPath = tableView.indexPathForRow(at: location)
            else {
                return nil
        }

        /// Prevent any Pan gesture from passing thru
        SPAppDelegate.shared().sidebarViewController.requirePanningToFail()

        /// Mark the source of the interaction
        previewingContext.sourceRect = tableView.rectForRow(at: indexPath)

        /// Setup the Editor
        let note = resultsController.object(at: indexPath)
        let editorViewController = SPAppDelegate.shared().noteEditorViewController
        editorViewController.update(note)
        editorViewController.isPreviewing = true
        editorViewController.searchString = searchText

        return editorViewController
    }

    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        guard let editorViewController = viewControllerToCommit as? SPNoteEditorViewController else {
            return
        }

        editorViewController.isPreviewing = false
        navigationController?.pushViewController(editorViewController, animated: true)
    }
}


// MARK: - Constants
//
private enum Constants {

    /// Where do these insets come from?
    /// `For other subviews in your view hierarchy, the default layout margins are normally 8 points on each side`
    ///
    /// We're replicating the (old) view herarchy's behavior, in which the SearchBar would actually be contained within a view with 8pt margins on each side.
    /// This won't be required anymore *soon*, and it's just a temporary workaround.
    ///
    /// Ref. https://developer.apple.com/documentation/uikit/uiview/1622566-layoutmargins
    ///
    static let searchBarInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
}
