import Foundation
import UIKit


// MARK: - InterlinkViewController
//
class InterlinkViewController: UIViewController {

    /// Closure to be executed whenever a Note is selected. The Interlink URL will be passed along.
    ///
    var onInsertInterlink: ((String) -> Void)?


    func refreshInterlinks(for keyword: String, excluding excludedID: NSManagedObjectID?) -> Bool {
// TODO: Implement Me!
        return true
    }
}
