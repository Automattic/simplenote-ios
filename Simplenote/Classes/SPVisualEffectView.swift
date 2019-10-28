import Foundation
import UIKit


// MARK: - UIVisualEffectView iOS <13 Dark Mode Friendly
//
@objc
class SPVisualEffectView: UIVisualEffectView {

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    init() {
        super.init(effect: UIBlurEffect.simplenoteBlurEffect)
        startListeningToNotifications()
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//
//
private extension SPVisualEffectView {

    ///
    ///
    func startListeningToNotifications() {
        // No need to do this in iOS +13
        if #available(iOS 13, *) {
            return
        }
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(refreshStyle), name: .VSThemeManagerThemeDidChange, object: nil)
    }

    ///
    ///
    @objc
    func refreshStyle() {
        effect = UIBlurEffect.simplenoteBlurEffect
    }
}
