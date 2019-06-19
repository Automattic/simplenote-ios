import Foundation


// MARK: - Simplenote's Date Methods
//
extension Date {

    /// Returns a Date instance representing "next week"
    ///
    static var oneWeekFromNow: Date? {
        let now = Date()
        return Calendar.current.date(byAdding: .weekOfYear, value: 1, to: now)
    }
}
