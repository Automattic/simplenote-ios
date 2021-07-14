import Foundation

extension Date {
    func increased(by days: Int) -> Date? {
        var components = DateComponents()
        components.day = days
        let calendar = Calendar.current
        return calendar.date(byAdding: components, to: self)
    }
}
