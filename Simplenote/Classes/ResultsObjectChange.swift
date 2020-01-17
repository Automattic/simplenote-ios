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


// MARK: - Equality
//
func ==(lhs: ResultsObjectChange, rhs: ResultsObjectChange) -> Bool {
    switch (lhs, rhs) {
    case (.delete(let lPath), .delete(let rPath)):
        return lPath == rPath
    case (.insert(let lPath), .insert(let rPath)):
        return lPath == rPath
    case (.move(let lOldPath, let lNewPath), .move(let rOldPath, let rNewPath)):
        return lOldPath == rOldPath && lNewPath == rNewPath
    case (.update(let lPath), .update(let rPath)):
        return lPath == rPath
    default:
        return false
    }
}
