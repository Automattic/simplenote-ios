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

    func performBatchChanges(objectChanges: [ResultsObjectChange], sectionChanges: [ResultsSectionChange], onCompletion: ((Bool) -> Void)? = nil) {
        let objectsChangeset = ResultsObjectsChangeset(objectChanges: objectChanges)
        let sectionsChangeset = ResultsSectionsChangeset(sectionChanges: sectionChanges)

        performBatchUpdates({
            self.performChanges(objectsChangeset: objectsChangeset, sectionsChangeset: sectionsChangeset)

        }, completion: onCompletion)
    }

    /// This API applies Section and Object Changesets over the receiver. Based on WWDC 2020 @ Labs Recommendations
    /// - Note: This should be done during onDidChangeContent so that we're never in the middle of a NSManagedObjectContext.save()
    ///
    func performChanges(objectsChangeset: ResultsObjectsChangeset, sectionsChangeset: ResultsSectionsChangeset, animations: ResultsTableAnimations = .standard) {
        // Step 1: Structural Changes: Delete OP(s)
        if !objectsChangeset.deleted.isEmpty {
            deleteRows(at: objectsChangeset.deleted, with: animations.delete)
        }

        if !sectionsChangeset.deleted.isEmpty {
            deleteSections(sectionsChangeset.deleted, with: animations.delete)
        }

        // Step 2: Structural Changes: Insert OP(s)
        if !sectionsChangeset.inserted.isEmpty {
            insertSections(sectionsChangeset.inserted, with: animations.insert)
        }

        if !objectsChangeset.inserted.isEmpty {
            insertRows(at: objectsChangeset.inserted, with: animations.insert)
        }

        // Step 3: Content Changes: Update OP(s)
        if !objectsChangeset.updated.isEmpty {
            reloadRows(at: objectsChangeset.updated, with: animations.update)
        }
    }
}
