import Foundation


// MARK: - ResultsObjectChange
//
enum ResultsObjectChange: Equatable {
    case delete(indexPath: IndexPath)
    case insert(indexPath: IndexPath)
    case move(oldIndexPath: IndexPath, newIndexPath: IndexPath)
    case update(indexPath: IndexPath)
}


// MARK: - ResultsObjectChange: Transposing
//
extension ResultsObjectChange {

    /// Why? Because displaying data coming from multiple ResultsController onScreen... just requires us to adjust sectionIndexes
    ///
    func transpose(toSection section: Int) -> ResultsObjectChange {
        switch self {
        case .delete(let path):
            return .delete(indexPath: path.transpose(toSection: section))

        case .insert(let path):
            return .insert(indexPath: path.transpose(toSection: section))

        case .move(let oldPath, let newPath):
            return .move(oldIndexPath: oldPath.transpose(toSection: section),
                         newIndexPath: newPath.transpose(toSection: section))

        case .update(let path):
            return .update(indexPath: path.transpose(toSection: section))
        }
    }
}
