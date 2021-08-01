import Foundation

extension Date {
    func increased(byDays days: Int) -> Date? {
        var components = DateComponents()
        components.day = days
        return Calendar.current.date(byAdding: components, to: self)
    }
}
