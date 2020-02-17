import Foundation


// MARK: - Simplenote Extension
//
extension DateFormatter {

    /// Shared DateFormatters
    ///
    struct Simplenote {
        static let listDateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter
        }()
    }
}
