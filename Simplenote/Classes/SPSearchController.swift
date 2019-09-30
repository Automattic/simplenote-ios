import Foundation
import UIKit


// MARK: - UISearchController Delegate Methods
//
@objc
protocol SPSearchControllerDelegate: NSObjectProtocol {
    func searchControllerShouldBeginSearch(_ controller: SPSearchController) -> Bool
    func searchController(_ controller: SPSearchController, didChange keyword: String)
    func searchControllerDidEndSearch(_ controller: SPSearchController)
}


// MARK: - Simplenote's Search Controller: Because UIKit's Search Controller is simply unusable
//
@objcMembers
class SPSearchController: NSObject {

    ///
    ///
    private(set) lazy var searchBar = UISearchBar()

    ///
    ///
    private(set) lazy var containerView = UIView()

    ///
    ///
    private var topConstraint: NSLayoutConstraint?

    ///
    ///
    var backgroundColor: UIColor? {
        get {
            containerView.backgroundColor
        }
        set {
            containerView.backgroundColor = newValue
        }
    }

    ///
    ///
    weak var delegate: SPSearchControllerDelegate?

    /// Designated Initializer
    ///
    override init() {
        super.init()
        setupSearchBar()
        setupContainerView()
        setupAutolayout()
    }

    /// Attaches the SearchBar + Background in the specified view's hierarchy
    ///
    func attach(to view: UIView) {
        view.addSubview(containerView)
        view.bringSubviewToFront(containerView)

        let sourceMarginsGuide = containerView.layoutMarginsGuide
        let targetMarginsGuide = view.layoutMarginsGuide
        let topConstraint = containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)

        NSLayoutConstraint.activate([
            sourceMarginsGuide.leadingAnchor.constraint(equalTo: targetMarginsGuide.leadingAnchor),
            sourceMarginsGuide.trailingAnchor.constraint(equalTo: targetMarginsGuide.trailingAnchor),
            topConstraint
        ])

        self.topConstraint = topConstraint
    }

    ///
    ///
    func reset() {
        searchBar.text = nil
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
}


// MARK: -
//
private extension SPSearchController {

    func setupSearchBar() {
        searchBar.placeholder = NSLocalizedString("Search", comment: "Search Placeholder")
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.sizeToFit()
// TODO
//    [self.searchBar applySimplenoteStyle];
    }

    func setupContainerView() {
        containerView.addSubview(searchBar)
    }

    func setupAutolayout() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: searchBar.frame.size.height),
            searchBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            searchBar.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
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


//    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
//
//    [_searchBar setBackgroundImage:[UIImage new]];
//    [_searchBar setBackgroundColor:[UIColor clearColor]];
//
//    UIEdgeInsets insets = self.tableView.contentInset;
//    insets.top += _searchBar.frame.size.height;
//    self.tableView.contentInset = insets;
