import Foundation
import CoreData


/// NSManagedObject: Object Conformance
///
extension NSManagedObject {

    /// Returns the Entity Name, if available, as specified in the NSEntityDescription. Otherwise, will return
    /// the subclass name.
    ///
    /// Note: entity().name returns nil as per iOS 10, in Unit Testing Targets. Awesome.
    ///
    public class var entityName: String {
        /// Note: As of iOS 12, spawning multiple CoreData Stack instances in Unit Tests may result in Console Errors
        /// ("This class is already claimed by another NSEntityDescription"). This error is triggered by the `entity()` method.
        /// For that reason, we're falling back to `classNameWithoutNamespaces()`, which keeps our console tidy.
        ///
        return classNameWithoutNamespaces
    }
}
