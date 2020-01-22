import Foundation
import CoreData


// MARK: - FetchedResultsControllerDelegateWrapper
//
class FetchedResultsControllerDelegateWrapper: NSObject {

    /// Relays FRC's Delegate: `controllerWillChangeContent`
    ///
    var onWillChangeContent: (() -> Void)?

    /// Relays FRC's Delegate: `controllerDidChangeContent`
    ///
    var onDidChangeContent: (() -> Void)?

    /// Relays FRC's Delegate: `didChange anObject`
    ///
    var onDidChangeObject: ((_ object: Any, _ type: NSFetchedResultsChangeType, _ indexPath: IndexPath?, _ newIndexPath: IndexPath?) -> Void)?

    /// Relays FRC's Delegate: `didChange sectionInfo`
    ///
    var onDidChangeSection: ((_ sectionInfo: NSFetchedResultsSectionInfo, _ sectionIndex: Int, _ type: NSFetchedResultsChangeType) -> Void)?
}


// MARK: - NSFetchedResultsControllerDelegate Conformance
//
extension FetchedResultsControllerDelegateWrapper: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onWillChangeContent?()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onDidChangeContent?()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        onDidChangeObject?(anObject, type, indexPath, newIndexPath)
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        onDidChangeSection?(sectionInfo, sectionIndex, type)
    }
}
