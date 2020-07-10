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
            let targetColor = SPUserInterface.isDark ? darkColor : lightColor
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
    static var simplenoteBlue30Color: UIColor {
        UIColor(studioColor: .spBlue30)
    }

    @objc
    static var simplenoteBlue50Color: UIColor {
        UIColor(studioColor: .spBlue50)
    }

    @objc
    static var simplenoteBlue60Color: UIColor {
        UIColor(studioColor: .spBlue60)
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
    static var simplenoteGray100Color: UIColor {
        UIColor(studioColor: .gray100)
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
    static var simplenoteNoteHeadlineColor: UIColor {
        UIColor(lightColor: .gray100, darkColor: .gray5)
    }

    @objc
    static var simplenoteNoteBodyPreviewColor: UIColor {
        UIColor(lightColor: .gray50, darkColor: .gray30)
    }

    @objc
    static var simplenoteNotePinStatusImageColor: UIColor {
        .simplenoteTintColor
    }

    @objc
    static var simplenoteNoteShareStatusImageColor: UIColor {
        UIColor(lightColor: .gray50, darkColor: .gray30)
    }

    @objc
    static var simplenoteLockBackgroundColor: UIColor {
        UIColor(lightColor: .spBlue50, darkColor: .darkGray1)
    }

    @objc
    static var simplenoteLockTextColor: UIColor {
        UIColor(studioColor: .white)
    }

    @objc
    static var simplenoteNavigationBarTitleColor: UIColor {
        UIColor(lightColor: .gray100, darkColor: .white)
    }

    @objc
    static var simplenotePlaceholderImageColor: UIColor {
        UIColor(studioColor: .gray5)
    }

    @objc
    static var simplenotePlaceholderTextColor: UIColor {
        UIColor(lightColor: .gray50, darkColor: .gray30)
    }

    @objc
    static var simplenoteSearchBarBackgroundColor: UIColor {
        UIColor(lightColor: .gray10, darkColor: .darkGray4)
    }

    @objc
    static var simplenoteSearchHighlightTextColor: UIColor {
        UIColor(studioColor: .white)
    }

    @objc
    static var simplenoteSwitchTintColor: UIColor {
        UIColor(lightColor: .gray5, darkColor: .darkGray3)
    }

    @objc
    static var simplenoteSwitchOnTintColor: UIColor {
        UIColor(lightColor: .green50, darkColor: .green30)
    }

    @objc
    static var simplenoteSecondaryActionColor: UIColor {
        UIColor(studioColor: .spBlue50)
    }

    @objc
    static var simplenoteTertiaryActionColor: UIColor {
        UIColor(studioColor: .gray40)
    }

    @objc
    static var simplenoteDestructiveActionColor: UIColor {
        UIColor(studioColor: .red50)
    }

    @objc
    static var simplenoteRestoreActionColor: UIColor {
        UIColor(lightColor: .spYellow0, darkColor: .spYellow10)
    }

    @objc
    static var simplenoteBackgroundColor: UIColor {
        UIColor(lightColor: .white, darkColor: .black)
    }

    @objc
    static var simplenoteNavigationBarBackgroundColor: UIColor {
        UIColor(lightColor: .white, darkColor: .black).withAlphaComponent(UIKitConstants.alpha0_8)
    }

    @objc
    static var simplenoteNavigationBarModalBackgroundColor: UIColor {
        UIColor(lightColor: .white, darkColor: .darkGray2).withAlphaComponent(UIKitConstants.alpha0_8)
    }

    @objc
    static var simplenoteSortBarBackgroundColor: UIColor {
        UIColor(lightColor: .spGray1, darkColor: .darkGray1).withAlphaComponent(UIKitConstants.alpha0_8)
    }

    @objc
    static var simplenoteModalOverlayColor: UIColor {
        UIColor(studioColor: .black).withAlphaComponent(UIKitConstants.alpha0_4)
    }

    @objc
    static var simplenoteTableViewBackgroundColor: UIColor {
        UIColor(lightColor: .gray0, darkColor: .darkGray1)
    }

    @objc
    static var simplenoteTableViewCellBackgroundColor: UIColor {
        UIColor(lightColor: .white, darkColor: .darkGray2)
    }

    @objc
    static var simplenoteTableViewHeaderBackgroundColor: UIColor {
        UIColor(lightColor: .spGray2, darkColor: .darkGray2)
    }

    @objc
    static var simplenoteWindowBackgroundColor: UIColor {
        UIColor(studioColor: .black)
    }

    @objc
    static var simplenoteDividerColor: UIColor {
        UIColor(lightColor: .gray40, darkColor: .darkGray4).withAlphaComponent(UIKitConstants.alpha0_6)
    }

    @objc
    static var simplenoteTitleColor: UIColor {
        UIColor(lightColor: .gray50, darkColor: .gray30)
    }

    @objc
    static var simplenoteTextColor: UIColor {
        UIColor(lightColor: .gray100, darkColor: .white)
    }

    @objc
    static var simplenoteTintColor: UIColor {
        UIColor(lightColor: .spBlue50, darkColor: .spBlue30)
    }

    @objc
    static var simplenoteLightBlueColor: UIColor {
        UIColor(lightColor: .spBlue5, darkColor: .darkGray3)
    }

    @objc
    static var simplenoteInteractiveTextColor: UIColor {
        UIColor(lightColor: .spBlue50, darkColor: .spBlue30)
    }

    @objc
    static var simplenoteTagViewTextColor: UIColor {
        UIColor(lightColor: .spBlue50, darkColor: .spBlue30)
    }

    @objc
    static var simplenoteTagViewPlaceholderColor: UIColor {
        UIColor(lightColor: .gray50, darkColor: .gray30)
    }

    @objc
    static var simplenoteTagViewCompleteColor: UIColor {
        UIColor(lightColor: .gray50, darkColor: .gray30)
    }


    @objc
    static var simplenoteTagViewCompleteHighlightedColor: UIColor {
        UIColor(lightColor: .gray30, darkColor: .gray50)
    }

    @objc
    static var simplenoteTagViewDeletionBackgroundColor: UIColor {
        UIColor(lightColor: .spBlue5, darkColor: .darkGray3)
    }




///    #### PENDINGS

    @objc
    static var simplenoteActionSheetButtonTitleColor: UIColor {
        UIColor(lightColor: .gray0, darkColor: .gray5)
    }

    @objc
    static var simplenoteActionSheetButtonBackgroundHighlightColor: UIColor {
        UIColor(lightColor: .gray0, darkColor: .gray5)
    }

    @objc
    static var simplenoteActionViewButtonDisabledColor: UIColor {
        UIColor(lightColor: .gray0, darkColor: .gray5)
    }

    @objc
    static var simplenoteActionViewStatusTextColor: UIColor {
        UIColor(lightColor: .gray0, darkColor: .gray5)
    }

    @objc
    static var simplenoteTableViewDetailTextColor: UIColor {
        UIColor(lightColor: .gray0, darkColor: .gray5)
    }
}
