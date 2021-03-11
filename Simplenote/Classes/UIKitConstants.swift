import Foundation
import UIKit


// MARK: - UIKit Constants, so that we don't repeat ourselves forever!
//
@objcMembers
class UIKitConstants: NSObject {
    static let alpha0_0 = CGFloat(0)
    static let alpha0_1 = CGFloat(0.1)
    static let alpha0_2 = CGFloat(0.2)
    static let alpha0_4 = CGFloat(0.4)
    static let alpha0_5 = CGFloat(0.5)
    static let alpha0_6 = CGFloat(0.6)
    static let alpha0_8 = CGFloat(0.8)
    static let alpha1_0 = CGFloat(1)
    static let animationDelayZero = TimeInterval(0)
    static let animationDelayShort = TimeInterval(0.25)
    static let animationDelayLong = TimeInterval(0.5)
    static let animationDelayExtraLong = TimeInterval(1.5)
    static let animationDelayExtraExtraLong = TimeInterval(2.75)
    static let animationQuickDuration = TimeInterval(0.1)
    static let animationShortDuration = TimeInterval(0.25)
    static let animationLongDuration = TimeInterval(0.5)
    static let animationTightDampening = CGFloat(0.9)

    /// Yes. This should be, potentially, an enum. But since we intend to use these constants in ObjC... oh well!
    ///
    private override init() {
        // NO-OP
    }
}
