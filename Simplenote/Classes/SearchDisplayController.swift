import Foundation
import UIKit


// MARK: - SearchDisplayController Delegate Methods
//
@objc
protocol SearchDisplayControllerDelegate: NSObjectProtocol {
    func searchDisplayControllerShouldBeginSearch(_ controller: SearchDisplayController) -> Bool
    func searchDisplayController(_ controller: SearchDisplayController, updateSearchResults keyword: String)
    func searchDisplayControllerWillBeginSearch(_ controller: SearchDisplayController)
    func searchDisplayControllerDidEndSearch(_ controller: SearchDisplayController)
}


// MARK: - SearchControllerPresentationContextProvider Methods
//
@objc
protocol SearchControllerPresentationContextProvider: NSObjectProtocol {
    func navigationControllerForSearchDisplayController(_ controller: SearchDisplayController) -> UINavigationController
}


// MARK: - Simplenote's Search Controller: Because UIKit's Search Controller is simply unusable
//
@objcMembers
class SearchDisplayController: NSObject {

    /// Indicates if the SearchController is active (or not!)
    ///
    private(set) var active = false

    /// Internal SearchBar Instance
    ///
    let searchBar = SPSearchBar()

    /// SearchController's Delegate
    ///
    weak var delegate: SearchDisplayControllerDelegate?

    /// SearchController's Presentation Context Provider
    ///
    weak var presenter: SearchControllerPresentationContextProvider?


    /// Designated Initializer
    ///
    override init() {
        super.init()
        setupSearchBar()
    }

    /// Dismissess the SearchBar
    ///
    func dismiss() {
        // Set the inactive status first, and THEN resign the responder.
        //
        // Why: Because of the `keyboardWillChangeFrame` Notification. We could really, really use
        // the actual status to be available when such note is posted. Capisci?
        //
        updateStatus(active: false)
        searchBar.text = nil
        searchBar.resignFirstResponder()
    }

    /// Updates the SearchBar's Text, and notifies the Delegate
    ///
    func updateSearchText(searchText: String) {
        searchBar.text = searchText
        delegate?.searchDisplayController(self, updateSearchResults: searchText)
    }

    /// This method will hide the NavigationBar whenever the SearchDisplayController is in active mode.
    ///
    /// We'll rely on this API to ensure transitions from List <> Editor are smooth: In Search Mode the list won't display the NavigationBar, but the
    /// Editor is always expected to display a navbar. When going backwards, we'll always need to restore the navbar.
    ///
    @objc
    func hideNavigationBarIfNecessary() {
        updateNavigationBar(hidden: active)
    }

    func setEnabled(_ enabled: Bool) {
        searchBar.isUserInteractionEnabled = enabled
        searchBar.alpha = enabled ? UIKitConstants.alpha1_0 : UIKitConstants.alpha0_5
    }
}


// MARK: - Private Methods
//
private extension SearchDisplayController {

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
extension SearchDisplayController: UISearchBarDelegate {

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

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
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
