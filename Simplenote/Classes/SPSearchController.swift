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
}


// MARK: - Simplenote's Search Controller: Because UIKit's Search Controller is simply unusable
//
@objcMembers
class SPSearchController: NSObject {

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
    override init() {
        super.init()
        setupSearchBar()
    }

    /// Dismissess the SearchBar
    ///
    func dismiss() {
        searchBar.text = nil
        searchBar.resignFirstResponder()
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


    func updateNavigationBar(hidden: Bool) {
        guard let navigationController = presenter?.navigationControllerForSearchController(self) else {
            return
        }

        guard navigationController.isNavigationBarHidden != hidden else {
            return
        }

        UIView.animate(withDuration: UIKitConstants.animationShortDuration) {
            navigationController.setNavigationBarHidden(hidden, animated: true)
            navigationController.view.layoutIfNeeded()
        }
    }

    func updateSearchBar(showsCancelButton: Bool) {
        guard showsCancelButton != searchBar.showsCancelButton else {
            return
        }

        searchBar.setShowsCancelButton(true, animated: true)
    }
}


// MARK: - UISearchBar Delegate Methods
//
extension SPSearchController: UISearchBarDelegate {

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        let output = delegate?.searchControllerShouldBeginSearch(self) ?? true
        if output {
            updateNavigationBar(hidden: true)
            updateSearchBar(showsCancelButton: true)
        }

        return output
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.searchController(self, updateSearchResults: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        updateSearchBar(showsCancelButton: false)
        updateNavigationBar(hidden: false)

        delegate?.searchControllerDidEndSearch(self)
    }
}
