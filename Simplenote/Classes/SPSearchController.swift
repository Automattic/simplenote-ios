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
        delegate?.searchController(self, updateSearchResults: searchText)
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
