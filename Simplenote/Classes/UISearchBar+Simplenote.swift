import Foundation
import UIKit


// MARK: - UISearchBar Simplenote Methods
//
extension UISearchBar {

    /// Yes. This is a hack. A quite violent one.
    ///
    /// Why do we need this?: UISearchController is attaching the SearchBar below the NavigationBar, and a 1pt line is being rendered.
    /// There is just no way to remove such line using a clean API. This workaround is to be applied on `iOS <13` devices, since, thanks god,
    /// iOS 13's behavior is what we expect.
    ///
    /// Important: This method should be called whenever`viewWillLayoutSubviews` is executed, otherwise the searchBar instance won't
    /// have its superview setup.
    ///
    @objc
    func removeBottomSeparatorOnIOS12AndBelow() {
        if #available(iOS 13, *) {
            return
        }

        guard let containerView = superview else {
            return
        }

        let targetClassName = "_UIBarBackground"
        for backgroundView in containerView.subviews {
            guard String(describing: type(of: backgroundView)) == targetClassName else {
                continue
            }

            backgroundView.isHidden = true
        }
    }
}
