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


// MARK: - Simplenote's Search Controller: Because UIKit's Search Controller is simply unusable
//
@objcMembers
class SPSearchController: NSObject {

    ///
    ///
    let searchBar = UISearchBar()

    /// SearchController's Delegate
    ///
    weak var delegate: SPSearchControllerDelegate?

    /// Designated Initializer
    ///
    override init() {
        super.init()
        setupSearchBar()
    }

    /// Attaches the SearchBar to a given target view
    ///
    func attachSearchBar(to view: UIView) {
        view.addSubview(searchBar)
        view.bringSubviewToFront(searchBar)

        let sourceMarginsGuide = searchBar.layoutMarginsGuide
        let targetMarginsGuide = view.layoutMarginsGuide

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            sourceMarginsGuide.leadingAnchor.constraint(equalTo: targetMarginsGuide.leadingAnchor),
            sourceMarginsGuide.trailingAnchor.constraint(equalTo: targetMarginsGuide.trailingAnchor),
        ])
    }

    ///
    ///
    func reset() {
        searchBar.text = nil
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
}


// MARK: - Private Methods
//
private extension SPSearchController {

    func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = NSLocalizedString("Search", comment: "Search Placeholder")
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.sizeToFit()
    }
}


// MARK: - UISearchBar Delegate Methods
//
extension SPSearchController: UISearchBarDelegate {

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return delegate?.searchControllerShouldBeginSearch(self) ?? true
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.searchController(self, didChange: searchText)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        delegate?.searchControllerDidEndSearch(self)
    }
}

// TODO
//    UIEdgeInsets insets = self.tableView.contentInset;
//    insets.top += _searchBar.frame.size.height;
//    self.tableView.contentInset = insets;
