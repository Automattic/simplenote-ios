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

    func performBatchChanges(objectChanges: [ResultsObjectChange], sectionChanges: [ResultsSectionChange], onCompletion: @escaping (Bool) -> Void) {
        let objectsChangeset = ResultsObjectsChangeset(objectChanges: objectChanges)
        let sectionsChangeset = ResultsSectionsChangeset(sectionChanges: sectionChanges)

        performBatchUpdates({
            self.performChanges(objectsChangeset: objectsChangeset, sectionsChangeset: sectionsChangeset)

        }, completion: onCompletion)
    }

    func performChanges(objectsChangeset: ResultsObjectsChangeset, sectionsChangeset: ResultsSectionsChangeset) {

    func performRowChanges(_ rowChanges: [ResultsObjectChange], animations: ResultsTableAnimations = .standard) {
        for change in rowChanges {
            performRowChange(change, animations: animations)
        }
    }

    func performSectionChanges(_ sectionChanges: [ResultsSectionChange], animations: ResultsTableAnimations = .standard) {
        for change in sectionChanges {
            performSectionChange(change, animations: animations)
        }
    }

    func performRowChange(_ rowChange: ResultsObjectChange, animations: ResultsTableAnimations = .standard) {
        switch rowChange {
        case .delete(let indexPath):
            deleteRows(at: [indexPath], with: animations.delete)

        case .insert(let newIndexPath):
            insertRows(at: [newIndexPath], with: animations.insert)

        case .move(let oldIndexPath, let newIndexPath):
            deleteRows(at: [oldIndexPath], with: animations.move)
            insertRows(at: [newIndexPath], with: animations.move)

            // WWDC 2020 @ Labs Recommendation
            reloadRows(at: [newIndexPath], with: animations.move)

        case .update(let indexPath):
            reloadRows(at: [indexPath], with: animations.update)
        }
    }

    func performSectionChange(_ sectionChange: ResultsSectionChange, animations: ResultsTableAnimations = .standard) {
        switch sectionChange {
        case .delete(let sectionIndex):
            deleteSections(IndexSet(integer: sectionIndex), with: animations.delete)

        case .insert(let sectionIndex):
            insertSections(IndexSet(integer: sectionIndex), with: animations.insert)
        }
    }
}
