import Foundation

/// Western Date
public struct WesternDate {
    public let year: Int
    public let month: Int
    public let day: Int
    public let hour: Int
    public let minute: Int
    public let second: Int

    public init(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0, second: Int = 0) {
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.minute = minute
        self.second = second
    }

    /// Create WesternDate from Julian day number
    /// - Parameters:
    ///   - julianDate: Julian day number
    ///   - calendarType: Calendar type (default: English)
    /// - Returns: WesternDate instance
    public static func fromJulian(_ julianDate: Double, calendarType: CalendarType = .english) -> WesternDate {
        return WesternDateKernel.julianToWestern(julianDate, calendarType)
    }

    /// Convert to Julian day number
    /// - Parameters:
    ///   - calendarType: Calendar type (default: English)
    ///   - sg: Starting Gregorian date (default: 0)
    /// - Returns: Julian day number
    public func toJulian(calendarType: CalendarType = .english, sg: Double = 0) -> Double {
        return WesternDateKernel.westernToJulian(year, month, day, hour, minute, second, calendarType, sg)
    }

    /// Convert to MyanmarDate
    /// - Returns: MyanmarDate instance
    public func toMyanmarDate() throws -> MyanmarDate {
        let jd = toJulian()
        return try MyanmarDateKernel.julianToMyanmarDate(jd)
    }

    /// Create WesternDate from Foundation Date
    /// - Parameter date: Foundation Date
    /// - Returns: WesternDate instance
    public static func from(_ date: Date) -> WesternDate {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        return WesternDate(
            year: components.year ?? 0,
            month: components.month ?? 0,
            day: components.day ?? 0,
            hour: components.hour ?? 0,
            minute: components.minute ?? 0,
            second: components.second ?? 0
        )
    }

    /// Convert to Foundation Date
    /// - Returns: Foundation Date
    public func toDate() -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        return Calendar.current.date(from: components)
    }
}

extension WesternDate: CustomStringConvertible {
    public var description: String {
        return String(format: "%04d-%02d-%02d %02d:%02d:%02d", year, month, day, hour, minute, second)
    }
}

extension WesternDate: Equatable {
    public static func == (lhs: WesternDate, rhs: WesternDate) -> Bool {
        return lhs.year == rhs.year &&
            lhs.month == rhs.month &&
            lhs.day == rhs.day &&
            lhs.hour == rhs.hour &&
            lhs.minute == rhs.minute &&
            lhs.second == rhs.second
    }
}
