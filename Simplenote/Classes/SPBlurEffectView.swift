import Foundation
import UIKit


// MARK: - SPBlurEffectView: Reacts automatically to UserInterfaceStyle Changes
//
@objc
class SPBlurEffectView: UIVisualEffectView {

    /// Blur's TintView
    ///
    private let tintView: UIView = {
        let output = UIView()
        output.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return output
    }()

    /// Closure that's expected to return the TintColor we want. Runs on `iOS <13` everytime the active Theme is updated.
    ///
    @objc
    var tintColorClosure: (() -> UIColor)? {
        didSet {
            refreshTintColor()
        }
    }


    // MARK: - Initializers

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    convenience init() {
        self.init(effect: .simplenoteBlurEffect)
    }

    convenience required init?(coder: NSCoder) {
        self.init(effect: .simplenoteBlurEffect)
    }

    init(effect: UIBlurEffect) {
        super.init(effect: effect)
        setupTintView()
        startListeningToNotifications()
    }
}


// MARK: - Private Methods
//
private extension SPBlurEffectView {

    func startListeningToNotifications() {
        // No need to do this in iOS +13
        if #available(iOS 13, *) {
            return
        }

        NotificationCenter.default.addObserver(self, selector: #selector(refreshStyle), name: .SPSimplenoteThemeChanged, object: nil)
    }

    func setupTintView() {
        contentView.addSubview(tintView)
    }

    @objc
    func refreshStyle() {
        refreshBlurEffect()
        refreshTintColor()
    }

    func refreshBlurEffect() {
        effect = UIBlurEffect.simplenoteBlurEffect
    }

    func refreshTintColor() {
        tintView.backgroundColor = tintColorClosure?()
    }
}


// MARK: - Static Methods
//
extension SPBlurEffectView {

    /// Adjust the receiver's alpha, to match a given ScrollView's ContentOffset
    ///
    @objc
    func adjustAlphaMatchingContentOffset(of scrollView: UIScrollView) {
        let maximumAlphaGradientOffset = CGFloat(22)
        let normalizedOffset = scrollView.adjustedContentInset.top + scrollView.contentOffset.y
        let newAlpha = min(max(normalizedOffset / maximumAlphaGradientOffset, 0), 1)

        guard alpha != newAlpha else {
            return
        }

        alpha = newAlpha
    }

    /// Returns a BlurEffectView meant to be used as a NavigationBar Background
    ///
    @objc
    static func navigationBarBlurView() -> SPBlurEffectView {
        let effectView = SPBlurEffectView()
        effectView.isUserInteractionEnabled = false
        effectView.tintColorClosure = {
            return .simplenoteNavigationBarBackgroundColor
        }

        return effectView
    }
}
