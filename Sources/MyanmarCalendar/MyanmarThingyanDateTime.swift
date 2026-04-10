import Foundation

/// Myanmar Thingyan Date Time
/// Provides Myanmar Date representations of all Thingyan-related days
public struct MyanmarThingyanDateTime {

    /// Thingyan Akyo day (သင်္ကြန်အကြိုနေ့)
    public let akyoDay: MyanmarDate

    /// Akya time (သင်္ကြန်ကျချိန်)
    public let akyaTime: MyanmarDate

    /// Akya day (အကျနေ့)
    public let akyaDay: MyanmarDate

    /// Atat Time (သင်္ကြန်တက်ချိန်)
    public let atatTime: MyanmarDate

    /// Atat day (သင်္ကြန်အတက်နေ့)
    public let atatDay: MyanmarDate

    /// Thingyan Akyat day (အကြတ်နေ့)
    public let akyatDays: [MyanmarDate]

    /// Myanmar New Year's Day (နှစ်ဆန်းတစ်ရက်နေ့)
    public let myanmarNewYearDay: MyanmarDate

    private init(myear: Int) throws {
        let thingyan = try Thingyan.of(myear)

        self.akyoDay = try MyanmarDate.of(julianDayNumber: thingyan.akyoDay)
        self.akyaTime = try MyanmarDate.of(julianDayNumber: thingyan.akyaTime)
        self.akyaDay = try MyanmarDate.of(julianDayNumber: thingyan.akyaDay)
        self.atatTime = try MyanmarDate.of(julianDayNumber: thingyan.atatTime)
        self.atatDay = try MyanmarDate.of(julianDayNumber: thingyan.atatDay)

        self.akyatDays = try thingyan.akyatDays.map { try MyanmarDate.of(julianDayNumber: $0) }
        self.myanmarNewYearDay = try MyanmarDate.of(julianDayNumber: thingyan.myanmarNewYearDay)
    }

    /// Creates a MyanmarThingyanDateTime instance for the specified Myanmar year
    /// - Parameter myear: The Myanmar year
    /// - Returns: A new instance of MyanmarThingyanDateTime
    /// - Throws: Error if the year is invalid
    public static func of(_ myear: Int) throws -> MyanmarThingyanDateTime {
        return try MyanmarThingyanDateTime(myear: myear)
    }
}

extension MyanmarThingyanDateTime: Equatable {
    public static func == (lhs: MyanmarThingyanDateTime, rhs: MyanmarThingyanDateTime) -> Bool {
        return lhs.akyoDay == rhs.akyoDay &&
            lhs.akyaTime == rhs.akyaTime &&
            lhs.akyaDay == rhs.akyaDay &&
            lhs.atatTime == rhs.atatTime &&
            lhs.atatDay == rhs.atatDay &&
            lhs.akyatDays == rhs.akyatDays &&
            lhs.myanmarNewYearDay == rhs.myanmarNewYearDay
    }
}
