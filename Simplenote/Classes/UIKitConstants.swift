import Foundation


// MARK: - UIKit Constants, so that we don't repeat ourselves forever!
//
@objcMembers
class UIKitConstants: NSObject {
    static let alphaZero = CGFloat(0)
    static let alphaMid = CGFloat(0.5)
    static let alphaFull = CGFloat(1)
    static let animationQuickDuration = TimeInterval(0.1)
    static let animationShortDuration = TimeInterval(0.25)
    static let animationTightDampening = CGFloat(0.9)

    /// Yes. This should be, potentially, an enum. But since we intend to use these constants in ObjC... oh well!
    ///
    private override init() {
        // NO-OP
    }
}
