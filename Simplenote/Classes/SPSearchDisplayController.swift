import Foundation
import UIKit


// MARK: - UISearchController Delegate Methods
//
@objc
protocol SPSearchControllerDelegate: NSObjectProtocol {
    func searchControllerShouldBeginSearch(_ controller: SPSearchDisplayController) -> Bool
    func searchController(_ controller: SPSearchDisplayController, updateSearchResults keyword: String)
    func searchControllerWillBeginSearch(_ controller: SPSearchDisplayController)
    func searchControllerDidEndSearch(_ controller: SPSearchDisplayController)
}


// MARK: - SPSearchControllerPresenter Delegate Methods
//
@objc
protocol SPSearchControllerPresentationContextProvider: NSObjectProtocol {
    func navigationControllerForSearchController(_ controller: SPSearchDisplayController) -> UINavigationController
    func resultsParentControllerForSearchController(_ controller: SPSearchDisplayController) -> UIViewController
}


// MARK: - SPSearchControllerResults: To be (optionally) implemented by specialized ResultsViewController(s)
//
protocol SPSearchControllerResults: NSObjectProtocol {
    var searchController: SPSearchDisplayController? { get set }
}


// MARK: - Simplenote's Search Controller: Because UIKit's Search Controller is simply unusable
//
@objcMembers
class SPSearchDisplayController: NSObject {

    /// Indicates if the SearchController is active (or not!)
    ///
    private var active = false

    /// ResultsController in which Search Results would be rendered
    ///
    let resultsViewController: UIViewController

    /// Internal SearchBar Instance
    ///
    let searchBar = SPSearchBar()

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
        setupResultsViewController()
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

    func setupResultsViewController() {
        // Analog to the old school `self.searchDisplayController` UIViewController property, we'll set our own
        let resultsController = (resultsViewController as? SPSearchControllerResults)
        resultsController?.searchController = self
    }

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
        updateResultsView(visible: active)
        updateNavigationBar(hidden: active)
        notifyStatusChanged(active: active)
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
        guard FeatureManager.advancedSearchEnabled else {
            return
        }

        guard visible else {
            dismissResultsViewController()
            return
        }

        displayResultsViewController()
    }

    func notifyStatusChanged(active: Bool) {
        if active {
            delegate?.searchControllerWillBeginSearch(self)
        } else {
            delegate?.searchControllerDidEndSearch(self)
        }
    }
}


// MARK: - ResultsViewController Methods
//
private extension SPSearchDisplayController {

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
extension SPSearchDisplayController: UISearchBarDelegate {

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
