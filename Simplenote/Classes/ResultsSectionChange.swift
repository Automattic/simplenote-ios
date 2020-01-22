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


// MARK: - Equality
//
func ==(lhs: ResultsSectionChange, rhs: ResultsSectionChange) -> Bool {
    switch (lhs, rhs) {
    case (.delete(let lSection), .delete(let rSection)):
        return lSection == rSection
    case (.insert(let lSection), .insert(let rSection)):
        return lSection == rSection
    default:
        return false
    }
}
