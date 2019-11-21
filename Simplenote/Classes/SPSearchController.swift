import Foundation
import UIKit


// MARK: - UISearchController Delegate Methods
//
@objc
protocol SPSearchControllerDelegate: NSObjectProtocol {
    func searchControllerShouldBeginSearch(_ controller: SPSearchController) -> Bool
    func searchController(_ controller: SPSearchController, updateSearchResults keyword: String)
    func searchControllerDidEndSearch(_ controller: SPSearchController)
}


// MARK: - SPSearchControllerPresenter Delegate Methods
//
@objc
protocol SPSearchControllerPresentationContextProvider: NSObjectProtocol {
    func navigationControllerForSearchController(_ controller: SPSearchController) -> UINavigationController
    func resultsParentControllerForSearchController(_ controller: SPSearchController) -> UIViewController
}


// MARK: - Simplenote's Search Controller: Because UIKit's Search Controller is simply unusable
//
@objcMembers
class SPSearchController: NSObject {

    /// ResultsController in which Search Results would be rendered
    ///
    let resultsViewController: UIViewController

    /// Internal SearchBar Instance
    ///
    let searchBar = UISearchBar()

    /// SearchController's Delegate
    ///
    weak var delegate: SPSearchControllerDelegate?

    /// SearchController's Presentation Context Provider
    ///
    weak var presenter: SPSearchControllerPresentationContextProvider?


    /// Designated Initializer
    ///
    init(resultsViewController: UIViewController) {
        self.resultsViewController = resultsViewController
        super.init()
        setupSearchBar()
    }

    /// Dismissess the SearchBar
    ///
    func dismiss() {
        searchBar.text = nil
        searchBar.resignFirstResponder()
        updateStatus(active: false)
    }
}


// MARK: - Private Methods
//
private extension SPSearchController {

    func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = NSLocalizedString("Search", comment: "Search Placeholder")
        searchBar.searchBarStyle = .minimal
        searchBar.sizeToFit()
    }

    func updateStatus(active: Bool) {
        updateSearchBar(showsCancelButton: active)
        updateResultsView(visible: active)
        updateNavigationBar(hidden: active)
    }

    func updateNavigationBar(hidden: Bool) {
        guard let navigationController = presenter?.navigationControllerForSearchController(self),
            navigationController.isNavigationBarHidden != hidden
            else {
                return
        }

        navigationController.setNavigationBarHidden(hidden, animated: true)

        UIView.animate(withDuration: TimeInterval(UINavigationController.hideShowBarDuration)) {
            navigationController.topViewController?.view?.layoutIfNeeded()
        }
    }

    func updateSearchBar(showsCancelButton: Bool) {
        guard showsCancelButton != searchBar.showsCancelButton else {
            return
        }

        searchBar.setShowsCancelButton(showsCancelButton, animated: true)
    }

    func updateResultsView(visible: Bool) {
        guard visible else {
            dismissResultsViewController()
            return
        }

        displayResultsViewController()
    }
}


// MARK: - SPSearchController
//
private extension SPSearchController {

    /// Displays the SearchResultsController onScreen
    ///
    func displayResultsViewController() {
        guard resultsViewController.parent == nil,
            let parentViewController = presenter?.resultsParentControllerForSearchController(self) else {
                return
        }

        resultsViewController.additionalSafeAreaInsets.top = searchBar.frame.size.height
        parentViewController.addChild(resultsViewController)

        attach(resultsView: resultsViewController.view, into: parentViewController.view)
        parentViewController.view.layoutIfNeeded()

        resultsViewController.view.fadeIn()
    }

    /// Dismisses the active ResultsViewController
    ///
    func dismissResultsViewController() {
        guard let _ = resultsViewController.parent else {
            return
        }

        resultsViewController.view.fadeOut {
            self.resultsViewController.view.removeFromSuperview()
            self.resultsViewController.removeFromParent()
        }
    }

    /// Attaches a given UIView instance into a containerView, and pints it to the four edges
    ///
    func attach(resultsView: UIView, into containerView: UIView) {
        resultsView.translatesAutoresizingMaskIntoConstraints = false
        containerView.insertSubview(resultsView, belowSubview: searchBar)
//        containerView.insertSubview(resultsView, belowSubview: navigationBarBackground)

        NSLayoutConstraint.activate([
            resultsView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            resultsView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            resultsView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            resultsView.topAnchor.constraint(equalTo: containerView.topAnchor)
        ])
    }

}


// MARK: - UISearchBar Delegate Methods
//
extension SPSearchController: UISearchBarDelegate {

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        guard let shouldBeginEditing = delegate?.searchControllerShouldBeginSearch(self) else {
            return false
        }

        updateStatus(active: shouldBeginEditing)

        return shouldBeginEditing
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.searchController(self, updateSearchResults: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss()
        delegate?.searchControllerDidEndSearch(self)
    }
}
