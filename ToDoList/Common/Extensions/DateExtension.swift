import Foundation
extension Date {
    static var tomorrow: Date { return Date().dayAfter }

    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }

    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }

    func format(with formatter: DateFormatter) -> String {
        return formatter.string(from: self)
    }
}
