import Foundation

// MARK: - NumberFormatter Extension
//
extension NumberFormatter {
    /// Number formatter with decimal style
    ///
    static let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
}
