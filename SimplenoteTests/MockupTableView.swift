import Foundation
import UIKit


// MARK: - UITableView Mockup
//
class MockupTableView: UITableView {

    /// Closure to be executed whenever `insertRows` is called.
    ///
    var onInsertedRows: (([IndexPath]) -> Void)?

    /// Closure to be executed whenever `deleteRows` is called.
    ///
    var onDeletedRows: (([IndexPath]) -> Void)?

    /// Closure to be executed whenever `reloadRows` is called.
    ///
    var onReloadRows: (([IndexPath]) -> Void)?

    /// Closure to be executed whenever `deleteSections` is called.
    ///
    var onDeletedSections: ((IndexSet) -> Void)?

    /// Closure to be executed whenever `insertSections` is called.
    ///
    var onInsertedSections: ((IndexSet) -> Void)?



    // MARK: - Overridden Methods

    override func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        onInsertedRows?(indexPaths)
    }

    override func deleteRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        onDeletedRows?(indexPaths)
    }

    override func reloadRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        onReloadRows?(indexPaths)
    }

    override func deleteSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
        onDeletedSections?(sections)
    }

    override func insertSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
        onInsertedSections?(sections)
    }
}
