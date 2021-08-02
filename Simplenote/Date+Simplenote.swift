import Foundation

extension Date {
    func increased(byHours hours: Int) -> Date? {
        var components = DateComponents()
        components.hour = hours
        return Calendar.current.date(byAdding: components, to: self)

    }
}
