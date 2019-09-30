import Foundation
import UIKit


// MARK: - Internal Methods
//
extension SPNoteListViewController {

    /// Registers the ListViewController for Peek and Pop events.
    ///
    @objc
    func registerForPeekAndPop() {
        registerForPreviewing(with: self, sourceView: tableView)
    }

    /// Refreshes the SearchBar Style.
    ///
    @objc
    func styleSearchBar(_ searchBar: UISearchBar) {
        let backgroundImage = UIImage()
        let backgroundColor = UIColor.color(name: .backgroundColor)?.withAlphaComponent(Constants.searchBarBackgroundAlpha)
        let searchIconColor = UIColor.color(name: .simplenoteSlateGrey)
        let searchIconImage = UIImage.image(name: .searchIconImage)?.withOverlayColor(searchIconColor)

        searchBar.backgroundColor = backgroundColor
        searchBar.setImage(searchIconImage, for: .search, state: .normal)
        searchBar.setBackgroundImage(backgroundImage, for: .any, barMetrics: .default)
        searchBar.setSearchFieldBackgroundImage(.searchBarBackgroundImage, for: .normal)
        searchBarContainer.backgroundColor = .clear

        // Apply font to search field by traversing subviews
        for textField in searchBar.subviewsOfType(UITextField.self) {
            textField.font = .preferredFont(forTextStyle: .body)
            textField.textColor = .color(name: .textColor)
            textField.keyboardAppearance = SPUserInterface.isDark ? .dark : .default
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


// MARK: - Constants
//
private enum Constants {

    /// SearchBar's Background Alpha, so that it matches with the navigationBar!
    ///
    static let searchBarBackgroundAlpha = CGFloat(0.9)
}
