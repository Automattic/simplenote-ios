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


// MARK: - ResultsController >> UITableView Events Forwarder.
//
extension ResultsController {

    /// Forwards Events to the specified UITableView Instance. We'll take care of Inserting / Deleting / Moving and Reloading Rows and Sections.
    ///
    func startForwardingEvents(to tableView: UITableView, with animations: ResultsTableAnimations = .standard) {
        startForwardingContentEvents(to: tableView, with: animations)
        startForwardingObjectEvents(to: tableView, with: animations)
        startForwardingSectionEvents(to: tableView, with: animations)
    }

    /// Stops forwarding Events: Effectively neutralizes all of the callbacks.
    ///
    func stopForwardingEvents() {
        onWillChangeContent = nil
        onDidChangeContent = nil
        onDidChangeObject = nil
        onDidChangeSection = nil
    }
}


// MARK: - Private Event Forwarding Methods
//
private extension ResultsController {

    /// Sets up all of the Content Events from the inner NSFetchedResultsController (FRC) over to the specified TableView.
    ///
    func startForwardingContentEvents(to tableView: UITableView, with animations: ResultsTableAnimations) {
        onWillChangeContent = { [weak tableView] in
            tableView?.beginUpdates()
        }

        onDidChangeContent = { [weak tableView] in
            tableView?.endUpdates()
        }
    }

    /// Sets up all of the Object Events from the inner FRC over to the specified TableView.
    ///
    func startForwardingObjectEvents(to tableView: UITableView, with animations: ResultsTableAnimations) {
        onDidChangeObject = { [weak tableView] (object, indexPath, type, newIndexPath) in
            guard let `tableView` = tableView else {
                return
            }

            // Seriously, Apple?
            // https://developer.apple.com/library/archive/releasenotes/iPhone/NSFetchedResultsChangeMoveReportedAsNSFetchedResultsChangeUpdate/index.html
            //
            let fixedType: ChangeType = {
                guard type == .update && newIndexPath != nil && newIndexPath != indexPath else {
                    return type
                }

                return .move
            }()

            switch fixedType {
            case .delete:
                if let indexPath = indexPath {
                    tableView.deleteRows(at: [indexPath], with: animations.delete)
                }
            case .insert:
                if let newIndexPath = newIndexPath {
                    tableView.insertRows(at: [newIndexPath], with: animations.insert)
                }
            case .move:
                if let oldIndexPath = indexPath {
                    tableView.deleteRows(at: [oldIndexPath], with: animations.move)
                }

                if let newIndexPath = newIndexPath {
                    tableView.insertRows(at: [newIndexPath], with: animations.move)
                }
            case .update:
                if let indexPath = indexPath {
                    tableView.reloadRows(at: [indexPath], with: animations.update)
                }
            @unknown default:
                fatalError()
            }
        }
    }

    /// Sets up all of the Section Events from the inner FRC over to the specified TableView.
    ///
    func startForwardingSectionEvents(to tableView: UITableView, with animations: ResultsTableAnimations) {
        onDidChangeSection = { [weak tableView] (sectionInfo, sectionIndex, type) in
            guard let `tableView` = tableView else {
                return
            }

            let sectionIndexSet = IndexSet(integer: sectionIndex)

            switch type {
            case .delete:
                tableView.deleteSections(sectionIndexSet, with: animations.delete)
            case .insert:
                tableView.insertSections(sectionIndexSet, with: animations.insert)
            default:
                NSLog("## ResultsController: Unsupported Section Event: \(type)")
            }
        }
    }
}
