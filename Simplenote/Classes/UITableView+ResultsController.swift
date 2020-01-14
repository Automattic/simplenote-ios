import Foundation
import UIKit


// MARK: - ResultsTableAnimations: Defines the Animations to be applied during Table Update(s)
//
struct ResultsTableAnimations {

    /// TableViewRowAnimation to be applied during Delete OP's.
    ///
    let delete: UITableView.RowAnimation = .fade

    /// TableViewRowAnimation to be applied during Insert OP's.
    ///
    let insert: UITableView.RowAnimation = .fade

    /// TableViewRowAnimation to be applied during Move OP's.
    ///
    let move: UITableView.RowAnimation = .fade

    /// TableViewRowAnimation to be applied during Update OP's.
    ///
    let update: UITableView.RowAnimation = .fade

    /// Standard ResultsTableAnimations Settings
    ///
    static let standard = ResultsTableAnimations()
}


// MARK: - UITableView ResultsController Convenience Methods
//
extension UITableView {

    func resultsController(didUpdateObject object: Any, indexPath: IndexPath?, type: ResultsChangeType, newIndexPath: IndexPath?, animations: ResultsTableAnimations = .standard) {
        // Seriously, Apple?
        // https://developer.apple.com/library/archive/releasenotes/iPhone/NSFetchedResultsChangeMoveReportedAsNSFetchedResultsChangeUpdate/index.html
        //
        let fixedType: ResultsChangeType = {
            guard type == .update && newIndexPath != nil && newIndexPath != indexPath else {
                return type
            }

            return .move
        }()

        switch fixedType {
        case .delete:
            if let indexPath = indexPath {
                deleteRows(at: [indexPath], with: animations.delete)
            }
        case .insert:
            if let newIndexPath = newIndexPath {
                insertRows(at: [newIndexPath], with: animations.insert)
            }
        case .move:
            if let oldIndexPath = indexPath {
                deleteRows(at: [oldIndexPath], with: animations.move)
            }

            if let newIndexPath = newIndexPath {
                insertRows(at: [newIndexPath], with: animations.move)
            }
        case .update:
            if let indexPath = indexPath {
                reloadRows(at: [indexPath], with: animations.update)
            }
        @unknown default:
            fatalError()
        }
    }

    func resultsController<T: NSManagedObject>(didChangeSectionInfo sectionInfo: ResultsSectionInfo<T>, sectionIndex: Int, type: ResultsChangeType, animations: ResultsTableAnimations = .standard) {
        let sectionIndexSet = IndexSet(integer: sectionIndex)

        switch type {
        case .delete:
            deleteSections(sectionIndexSet, with: animations.delete)
        case .insert:
            insertSections(sectionIndexSet, with: animations.insert)
        default:
            NSLog("## ResultsController: Unsupported Section Event: \(type)")
        }
    }
}
