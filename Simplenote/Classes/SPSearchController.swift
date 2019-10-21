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

    /// When the navigationBar is hidden, there'll be a gap between the top of the screen and the searchBar. We intend to compensate for that with a helper BG View!
    ///
    private lazy var statusBarBackground: UIView = {
        let backgroundView = UIView()
        backgroundView.alpha = UIKitConstants.alphaZero
        backgroundView.isUserInteractionEnabled = false
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        return backgroundView
    }()

    /// Internal SearchBar Instance
    ///
    let searchBar = UISearchBar()

    /// Indicates if we should inject a background behind
    ///
    var injectsStatusBarBackgroundView = false

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
        updateNavigationBar(hidden: active)
    }

    func updateNavigationBar(hidden: Bool) {
        guard let navigationController = presenter?.navigationControllerForSearchController(self),
            navigationController.isNavigationBarHidden != hidden
            else {
                return
        }

        statusBarBackground.backgroundColor = searchBar.backgroundColor
        statusBarBackground.alpha = hidden ? UIKitConstants.alphaMid : UIKitConstants.alphaFull

        UIView.animate(withDuration: UIKitConstants.animationShortDuration) { [weak self] in
            self?.statusBarBackground.alpha = hidden ? UIKitConstants.alphaFull : UIKitConstants.alphaZero
            navigationController.setNavigationBarHidden(hidden, animated: true)
            navigationController.view.layoutIfNeeded()
        }
    }

    func updateSearchBar(showsCancelButton: Bool) {
        guard showsCancelButton != searchBar.showsCancelButton else {
            return
        }

        searchBar.setShowsCancelButton(showsCancelButton, animated: true)
    }
}


// MARK: - StatusBar Background
//
extension SPSearchController {

    func ensureSearchBarBackgroundIsAttached() {
        guard injectsStatusBarBackgroundView,
            let superview = searchBar.superview,
            statusBarBackground.superview != superview
            else {
                return
        }

        superview.addSubview(statusBarBackground)

        NSLayoutConstraint.activate([
            statusBarBackground.topAnchor.constraint(equalTo: superview.topAnchor),
            statusBarBackground.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor),
            statusBarBackground.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            statusBarBackground.trailingAnchor.constraint(equalTo: superview.trailingAnchor)
        ])

        superview.layoutIfNeeded()
    }
}


// MARK: - UISearchBar Delegate Methods
//
extension SPSearchController: UISearchBarDelegate {

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        guard let shouldBeginEditing = delegate?.searchControllerShouldBeginSearch(self) else {
            return false
        }

        ensureSearchBarBackgroundIsAttached()
        updateStatus(active: shouldBeginEditing)

        return shouldBeginEditing
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.searchController(self, updateSearchResults: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        updateStatus(active: false)
        delegate?.searchControllerDidEndSearch(self)
    }
}
