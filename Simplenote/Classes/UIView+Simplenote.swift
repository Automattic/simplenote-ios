import Foundation
import UIKit


// MARK: - UIView's Simplenote Methods
//
extension UIView {

    /// Indicates if the receiver has the horizontal compact trait
    ///
    @objc
    func isHorizontallyCompact() -> Bool {
        return traitCollection.horizontalSizeClass == .compact
    }

    /// Returns all of the subviews of a given type
    ///
    func subviewsOfType<T: UIView>(_ type: T.Type) -> [T] {
        var output = [T]()

        for subview in subviews {
            output += subview.subviewsOfType(type)

            if let subview = subview as? T {
                output.append(subview)
            }
        }

        return output
    }
}


// MARK: - UIView Class Methods
//
extension UIView {

    /// Returns the Nib associated with the received: It's filename is expected to match the Class Name
    ///
    @objc
    class func loadNib() -> UINib {
        return UINib(nibName: classNameWithoutNamespaces, bundle: nil)
    }

    /// Returns the first Object contained within the nib with a name whose name matches with the receiver's type.
    /// Note: On error this method is expected to break, by design!
    ///
    class func instantiateFromNib<T>() -> T {
        return loadNib().instantiate(withOwner: nil, options: nil).first as! T
    }

    /// ObjC Convenience wrapper: Returns the first object contained within the receiver's nib.
    /// It's exactly the same as `instantiateFromNib`... but naming it differently to avoid collisions!
    ///
    @objc
    class func loadFromNib() -> Any? {
        return loadNib().instantiate(withOwner: nil, options: nil).first
    }
}
