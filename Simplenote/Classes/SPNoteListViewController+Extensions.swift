import Foundation
import UIKit


// MARK: - Interface Initialization
//
extension SPNoteListViewController {

    /// Sets up the Root ViewController
    ///
    @objc
    func configureRootView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false

        rootView.addSubview(tableView)
        rootView.addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: rootView.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: rootView.layoutMarginsGuide.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: rootView.layoutMarginsGuide.trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: rootView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: rootView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: rootView.bottomAnchor),
        ])
    }

    /// Adjust the TableView's Insets, so that the content falls below the searchBar
    ///
    @objc
    func refreshTableViewInsets() {
        tableView.contentInset.top = searchBar.frame.height
        tableView.scrollIndicatorInsets.top = searchBar.frame.height
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
        case kSimplenoteTagTrashKey:
            title = NSLocalizedString("Trash-noun", comment: "Title: Trash Tag is selected")
        default:
            title = selectedTag
        }
    }
}


// MARK: - UIViewControllerPreviewingDelegate Conformance
//
extension SPNoteListViewController: UIViewControllerPreviewingDelegate {

    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else {
            return nil
        }

        /// Prevent any Pan gesture from passing thru
        panGestureRecognizer.fail()

        /// Mark the source of the interaction
        previewingContext.sourceRect = tableView.rectForRow(at: indexPath)

        /// Setup the Editor
        let note = fetchedResultsController.object(at: indexPath)
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
