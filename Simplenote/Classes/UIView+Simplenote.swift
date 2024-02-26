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

    /// Adjusts the receiver's size for a  compressed layout
    ///
    @objc
    func adjustSizeForCompressedLayout() {
        frame.size = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
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

    /// Returns the enclosing TextView, if any
    ///
    @objc
    func enclosingTextView() -> UITextView? {
        if let textView = self as? UITextView {
            return textView
        }

        return superview?.enclosingTextView()
    }

    /// Returns the first subview in the receiver's hierarchy, downcasted as a UITableView. Returns nil, of course, if it's not a TableView!
    ///
    @objc
    func firstSubviewAsTableView() -> UITableView? {
        return subviews.first as? UITableView
    }

    /// Returns the Receiver's User Interface Direction
    ///
    @objc
    var userInterfaceLayoutDirection: UIUserInterfaceLayoutDirection {
        UIView.userInterfaceLayoutDirection(for: semanticContentAttribute)
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
