import Foundation


// MARK: - ResultsSectionChange
//
enum ResultsSectionChange: Equatable {
    case delete(sectionIndex: Int)
    case insert(sectionIndex: Int)
}


// MARK: - ResultsSectionChange: Transposing
//
extension ResultsSectionChange {

    /// Why? Because displaying data coming from multiple ResultsController onScreen... just requires us to adjust sectionIndexes
    ///
    func transpose(toSection section: Int) -> ResultsSectionChange {
        switch self {
        case .delete:
            return .delete(sectionIndex: section)
        case .insert:
            return .insert(sectionIndex: section)
        }
    }
}
