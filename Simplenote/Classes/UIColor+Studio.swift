import Foundation


// MARK: -
//
extension UIColor {

    /// Initializes a new UIColor instance with a given ColorStudio value
    ///
    convenience init(studioColor: ColorStudio) {
        self.init(hexString: studioColor.rawValue)
    }

    /// Initializes a new UIColor instance with a given ColorStudio Dark / Light set.
    /// Note: in `iOS <13` this method will always return a UIColor matching the `Current` Interface mode
    ///
    convenience init(lightColor: ColorStudio, darkColor: ColorStudio) {
        guard #available(iOS 13.0, *) else {
            let targetColor = SPUserInterface.isDark ? lightColor : darkColor
            self.init(studioColor: targetColor)
            return
        }

        self.init(dynamicProvider: { traits in
            let targetColor = traits.userInterfaceStyle == .dark ? darkColor : lightColor
            return UIColor(studioColor: targetColor)
        })
    }
}


// MARK: - Simplenote colors!
//
extension UIColor {

    @objc
    static var simplenoteBlue50Color: UIColor {
        UIColor(studioColor: .blue50)
    }

    @objc
    static var simplenoteBlue60Color: UIColor {
        UIColor(studioColor: .blue60)
    }

    @objc
    static var simplenoteGray5Color: UIColor {
        UIColor(studioColor: .gray5)
    }

    @objc
    static var simplenoteGray10Color: UIColor {
        UIColor(studioColor: .gray10)
    }

    @objc
    static var simplenoteGray20Color: UIColor {
        UIColor(studioColor: .gray20)
    }

    @objc
    static var simplenoteGray50Color: UIColor {
        UIColor(studioColor: .gray50)
    }

    @objc
    static var simplenoteGray60Color: UIColor {
        UIColor(studioColor: .gray60)
    }

    @objc
    static var simplenoteGray80Color: UIColor {
        UIColor(studioColor: .gray80)
    }

    @objc
    static var simplenoteRed50Color: UIColor {
        UIColor(studioColor: .red50)
    }

    @objc
    static var simplenoteRed60Color: UIColor {
        UIColor(studioColor: .red60)
    }

    @objc
    static var simplenoteWPBlue50Color: UIColor {
        UIColor(studioColor: .wpBlue50)
    }

    @objc
    static var simplenoteLockBackgroundColor: UIColor {
        UIColor(lightColor: .blue50, darkColor: .darkGray1)
    }

    @objc
    static var simplenoteLockTextColor: UIColor {
        UIColor(studioColor: .white)
    }

    @objc
    static var simplenoteSearchHighlightTextColor: UIColor {
        UIColor(studioColor: .white)
    }

    @objc
    static var simplenoteSwitchTintColor: UIColor {
        UIColor(lightColor: .gray5, darkColor: .darkGray4)
    }

    @objc
    static var simplenoteSwitchOnTintColor: UIColor {
        UIColor(lightColor: .green50, darkColor: .green30)
    }

    @objc
    static var simplenoteSecondaryActionColor: UIColor {
        UIColor(lightColor: .spYellow0, darkColor: .spYellow10)
    }

    @objc
    static var simplenoteTertiaryActionColor: UIColor {
        UIColor(lightColor: .gray30, darkColor: .gray50)
    }

    @objc
    static var simplenoteDestructiveActionColor: UIColor {
        UIColor(lightColor: .red50, darkColor: .red40)
    }
}
