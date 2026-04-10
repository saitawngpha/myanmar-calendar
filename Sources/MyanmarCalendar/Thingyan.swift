import Foundation

/// Thingyan (Myanmar New Year) calculations
/// Atat Time, Akya Time, Atat Day, Akya Day
public struct Thingyan {

    /// Atat Time (သင်္ကြန်တက်ချိန်) - Julian date time
    public let atatTime: Double

    /// Akya Time (သင်္ကြန်ကျချိန်) - Julian date time
    public let akyaTime: Double

    /// Atat Day (သင်္ကြန်အတက်နေ့) - Julian date
    public let atatDay: Double

    /// Akya Day (အကျနေ့) - Julian date
    public let akyaDay: Double

    private init(atatTime: Double, akyaTime: Double, atatDay: Double, akyaDay: Double) {
        self.atatTime = atatTime
        self.akyaTime = akyaTime
        self.atatDay = atatDay
        self.akyaDay = akyaDay
    }

    /// Calculate the Thingyan (Myanmar new year)
    /// - Parameter myear: Myanmar year
    /// - Returns: Thingyan object
    /// - Throws: Error if year is before 1100
    public static func of(_ myear: Int) throws -> Thingyan {
        let bgntg = 1100
        guard myear >= bgntg else {
            throw MyanmarDateKernel.MyanmarDateError.invalidJulianDayNumber("Thingyan starting from \(bgntg) of myanmar year.")
        }
        return algorithm(myear)
    }

    private static func algorithm(_ myear: Int) -> Thingyan {
        // Atat Time
        let ja = Constants.SY * Double(myear) + Constants.MO

        // Akya Time
        let jk: Double
        if myear >= Constants.SE3 {
            jk = ja - 2.169918982
        } else {
            jk = ja - 2.1675
        }

        // Atat Day
        let da = ja.rounded()
        // Akya Day
        let dk = jk.rounded()

        return Thingyan(atatTime: ja, akyaTime: jk, atatDay: da, akyaDay: dk)
    }

    /// Thingyan Akyo day (သင်္ကြန်အကြိုနေ့) - Julian date
    public var akyoDay: Double {
        return akyaDay - 1
    }

    /// Thingyan Akyat day (အကြတ်နေ့) - Julian dates
    public var akyatDays: [Double] {
        if (atatDay - akyaDay) > 2 {
            return [akyaDay + 1, akyaDay + 2]
        }
        return [akyaDay + 1]
    }

    /// Myanmar New Year's Day (နှစ်ဆန်းတစ်ရက်နေ့) - Julian date
    public var myanmarNewYearDay: Double {
        return atatDay + 1
    }
}

extension Thingyan: CustomStringConvertible {
    public var description: String {
        return "Thingyan[Atat Time=\(atatTime), Akya Time=\(akyaTime), Atat Day=\(atatDay), Akya Day=\(akyaDay)]"
    }
}

extension Thingyan: Equatable {
    public static func == (lhs: Thingyan, rhs: Thingyan) -> Bool {
        return lhs.atatTime == rhs.atatTime &&
            lhs.akyaTime == rhs.akyaTime &&
            lhs.atatDay == rhs.atatDay &&
            lhs.akyaDay == rhs.akyaDay
    }
}

extension Thingyan: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(atatTime)
        hasher.combine(akyaTime)
        hasher.combine(atatDay)
        hasher.combine(akyaDay)
    }
}
