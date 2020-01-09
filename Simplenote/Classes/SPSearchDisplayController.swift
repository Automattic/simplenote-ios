import Foundation
import UIKit


// MARK: - SPSearchDisplayController Delegate Methods
//
@objc
protocol SPSearchDisplayControllerDelegate: NSObjectProtocol {
    func searchDisplayControllerShouldBeginSearch(_ controller: SPSearchDisplayController) -> Bool
    func searchDisplayController(_ controller: SPSearchDisplayController, updateSearchResults keyword: String)
    func searchDisplayControllerWillBeginSearch(_ controller: SPSearchDisplayController)
    func searchDisplayControllerDidEndSearch(_ controller: SPSearchDisplayController)
}


// MARK: - SPSearchControllerPresenter Delegate Methods
//
@objc
protocol SPSearchControllerPresentationContextProvider: NSObjectProtocol {
    func navigationControllerForSearchDisplayController(_ controller: SPSearchDisplayController) -> UINavigationController
}


// MARK: - Simplenote's Search Controller: Because UIKit's Search Controller is simply unusable
//
@objcMembers
class SPSearchDisplayController: NSObject {

    /// Indicates if the SearchController is active (or not!)
    ///
    private var active = false

    /// Internal SearchBar Instance
    ///
    let searchBar = SPSearchBar()

    /// SearchController's Delegate
    ///
    weak var delegate: SPSearchDisplayControllerDelegate?

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
private extension SPSearchDisplayController {

    func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = NSLocalizedString("Search", comment: "Search Placeholder")
        searchBar.searchBarStyle = .minimal
        searchBar.sizeToFit()
    }

    func updateStatus(active: Bool) {
        guard active != self.active else {
            return
        }

        self.active = active

        updateSearchBar(showsCancelButton: active)
        updateNavigationBar(hidden: active)
        notifyStatusChanged(active: active)
    }

    func updateNavigationBar(hidden: Bool) {
        guard let navigationController = presenter?.navigationControllerForSearchDisplayController(self),
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

    func notifyStatusChanged(active: Bool) {
        if active {
            delegate?.searchDisplayControllerWillBeginSearch(self)
        } else {
            delegate?.searchDisplayControllerDidEndSearch(self)
        }
    }
}


// MARK: - UISearchBar Delegate Methods
//
extension SPSearchDisplayController: UISearchBarDelegate {

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        guard let shouldBeginEditing = delegate?.searchDisplayControllerShouldBeginSearch(self) else {
            return false
        }

        updateStatus(active: shouldBeginEditing)

        return shouldBeginEditing
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.searchDisplayController(self, updateSearchResults: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss()
    }
}


// MARK: - SPSearchBar
//
class SPSearchBar: UISearchBar {

    /// **Custom** Behavior:
    /// Normally resigning FirstResponder status implies all of the button subviews (ie. cancel button) to become disabled. This implies that
    /// hiding the keyboard makes it impossible to simply tap `Cancel` to exit **Search Mode**.
    ///
    /// With this (relatively safe) workaround, we're keeping any UIButton subview(s)  enabled, so that you can just exit Search Mode anytime.
    ///
    @discardableResult
    override func resignFirstResponder() -> Bool {
        let output = super.resignFirstResponder()

        for button in subviewsOfType(UIButton.self) {
            button.isEnabled = true
        }

        return output
    }
}
