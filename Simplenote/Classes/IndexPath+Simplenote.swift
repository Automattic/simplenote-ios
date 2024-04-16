import Foundation

// MARK: - IndexPath
//
extension IndexPath {

    func transpose(toSection newSection: Int) -> IndexPath {
        IndexPath(row: row, section: newSection)
    }
}
