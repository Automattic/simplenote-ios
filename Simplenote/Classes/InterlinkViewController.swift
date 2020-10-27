import Foundation
import UIKit


// MARK: - InterlinkViewController
//
class InterlinkViewController: UIViewController {

    /// Closure to be executed whenever a Note is selected. The Interlink URL will be passed along.
    ///
    var onInsertInterlink: ((String) -> Void)?


}


// MARK: - Presenting
//
extension InterlinkViewController {

    ///
    ///
    func positionView(around range: Range<String.Index>, in textView: UITextView) {
        let locationInView = textView.locationInSuperviewForText(in: range)
        view.frame.origin = locationInView.origin
    }
}


// MARK: -
//
extension InterlinkViewController {

    func refreshInterlinks(for keyword: String, excluding excludedID: NSManagedObjectID?) -> Bool {
// TODO: Implement Me!
        return true
    }
}
