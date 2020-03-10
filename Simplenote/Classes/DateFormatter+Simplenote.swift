import Foundation


// MARK: - Simplenote Extension
//
extension DateFormatter {

    /// Shared DateFormatters
    ///
    struct Simplenote {
        static let listDateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            return formatter
        }()
    }
}
