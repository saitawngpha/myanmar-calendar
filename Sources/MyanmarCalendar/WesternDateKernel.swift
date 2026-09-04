import Foundation

/// Core Calculation and Algorithm for Western Date
public struct WesternDateKernel {

    private init() {}

    /// Julian date to Western date
    /// - Parameters:
    ///   - julianDate: julian date
    ///   - calendarType: CalendarType enum
    /// - Returns: WesternDate object
    public static func julianToWestern(_ julianDate: Double, _ calendarType: CalendarType) -> WesternDate {
        return julianToWestern(julianDate, calendarType.number, 0)
    }

    /// Julian date to Western date
    /// - Parameters:
    ///   - julianDate: julian date
    ///   - calType: calendar type [0=english (default), 1=Gregorian, 2=Julian]
    ///   - sg: Beginning of Gregorian calendar in JDN [default=2361222]
    /// - Returns: WesternDate object
    public static func julianToWestern(_ julianDate: Double, _ calType: Int, _ sg: Double) -> WesternDate {

        let adjustedCalType = max(0, calType)
        // Gregorian start in English calendar (1752/Sep/14)
        let adjustedSG = sg <= 0 ? 2361222 : sg

        var j: Double
        var jf: Double
        var y: Double
        var m: Double
        var d: Double

        if adjustedCalType == 2 || (adjustedCalType == 0 && julianDate < adjustedSG) {
            j = floor(julianDate + 0.5)
            jf = julianDate + 0.5 - j
            let b = j + 1524
            let c = floor((b - 122.1) / 365.25)
            let f = floor(365.25 * c)
            let e = floor((b - f) / 30.6001)
            m = (e > 13) ? (e - 13) : (e - 1)
            d = b - f - floor(30.6001 * e)
            y = m < 3 ? (c - 4715) : (c - 4716)
        } else {
            j = floor(julianDate + 0.5)
            jf = julianDate + 0.5 - j
            j -= 1721119
            y = floor((4 * j - 1) / 146097.0)
            j = 4 * j - 1 - 146097 * y
            d = floor(j / 4)
            j = floor((4 * d + 3) / 1461.0)
            d = 4 * d + 3 - 1461 * j
            d = floor((d + 4) / 4.0)
            m = floor((5 * d - 3) / 153.0)
            d = 5 * d - 3 - 153 * m
            d = floor((d + 5) / 5.0)
            y = 100 * y + j
            if m < 10 {
                m += 3
            } else {
                m -= 9
                y = y + 1
            }
        }

        jf *= 24
        let hour = floor(jf)
        jf = (jf - hour) * 60
        let minute = floor(jf)
        let second = round((jf - minute) * 60)

        return WesternDate(year: Int(y), month: Int(m), day: Int(d), hour: Int(hour), minute: Int(minute), second: Int(second))
    }

    /// Western date to Julian day number
    /// - Parameters:
    ///   - year: western year
    ///   - month: month [Jan=1, ... , Dec=12]
    ///   - day: day [0-31]
    ///   - calType: calendar type [0=english (default), 1=Gregorian, 2=Julian]
    ///   - sg: Beginning of Gregorian calendar in JDN [default=2361222]
    /// - Returns: Julian day number
    public static func westernToJulian(_ year: Int, _ month: Int, _ day: Int, _ calType: Int, _ sg: Double) -> Double {

        let adjustedCalType = max(0, calType)
        // Gregorian start in English calendar (1752/Sep/14)
        let adjustedSG = sg <= 0 ? 2361222 : sg

        let a = Int(floor(Double(14 - month) / 12.0))
        let adjustedYear = year + 4800 - a
        let adjustedMonth = month + (12 * a) - 3

        var jd = Double(day) + floor(Double(153 * adjustedMonth + 2) / 5.0) + Double(365 * adjustedYear) + floor(Double(adjustedYear) / 4.0)

        if adjustedCalType == 1 {
            jd = jd - floor(Double(adjustedYear) / 100.0) + floor(Double(adjustedYear) / 400.0) - 32045
        } else if adjustedCalType == 2 {
            jd = jd - 32083
        } else {
            jd = jd - floor(Double(adjustedYear) / 100.0) + floor(Double(adjustedYear) / 400.0) - 32045
            if jd < adjustedSG {
                jd = Double(day) + floor(Double(153 * adjustedMonth + 2) / 5.0) + Double(365 * adjustedYear) + floor(Double(adjustedYear) / 4.0) - 32083
                if jd > adjustedSG {
                    jd = adjustedSG
                }
            }
        }

        return jd
    }

    /// Western date to Julian day number
    /// - Parameters:
    ///   - year: Year
    ///   - month: Month
    ///   - day: Day
    ///   - calendarType: CalendarType enum
    ///   - sg: Beginning of Gregorian calendar in JDN
    /// - Returns: Julian day number
    public static func westernToJulian(_ year: Int, _ month: Int, _ day: Int, _ calendarType: CalendarType, _ sg: Double) -> Double {
        return westernToJulian(year, month, day, calendarType.number, sg)
    }

    /// Western date to Julian day number with time
    /// - Parameters:
    ///   - year: Year
    ///   - month: Month
    ///   - day: Day
    ///   - hour: Hour
    ///   - minute: Minute
    ///   - second: Second
    ///   - calendarType: CalendarType enum
    ///   - sg: Beginning of Gregorian calendar in JDN
    /// - Returns: Julian day number
    public static func westernToJulian(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int, _ second: Int, _ calendarType: CalendarType, _ sg: Double) -> Double {
        let fractionOfDay = timeToDayFractionStartFrom12Noon(Double(hour), Double(minute), Double(second))
        return westernToJulian(year, month, day, calendarType.number, sg) + fractionOfDay
    }

    /// Time to Fraction of day starting from 12 noon
    /// - Parameters:
    ///   - hour: hour
    ///   - minute: minute
    ///   - second: second
    /// - Returns: fraction of day
    public static func timeToDayFractionStartFrom12Noon(_ hour: Double, _ minute: Double, _ second: Double) -> Double {
        return (hour - 12) / 24 + minute / 1440 + second / 86400
    }

    /// Julian day number of start of month
    /// - Parameters:
    ///   - year: Western Year
    ///   - month: Western Month [Jan=1, ... , Dec=12]
    ///   - calendarType: Calendar type
    /// - Returns: julian day number of start of month
    public static func getJulianDayNumberOfStartOfMonth(_ year: Int, _ month: Int, _ calendarType: CalendarType) -> Int {
        return Int(westernToJulian(year, month, 1, calendarType.number, 0))
    }

    /// Julian day number of end of the month
    /// - Parameters:
    ///   - year: Year
    ///   - month: Month
    ///   - calendarType: Calendar type
    /// - Returns: Julian day number of end of the month
    public static func getJulianDayNumberOfEndOfMonth(_ year: Int, _ month: Int, _ calendarType: CalendarType) -> Int {
        let js = getJulianDayNumberOfStartOfMonth(year, month, calendarType)
        let eml = getLengthOfMonth(year, month, calendarType.number)
        return js + eml - 1
    }

    /// Find the length of a month
    /// - Parameters:
    ///   - year: Year
    ///   - month: Month [Jan=1, ... , Dec=12]
    ///   - calendarType: [0=English, 1=Gregorian, 2=Julian]
    /// - Returns: the length of a month
    public static func getLengthOfMonth(_ year: Int, _ month: Int, _ calendarType: Int) -> Int {
        var leap = 0
        // length of the current month
        var mLen = 30 + Int((Double(month) + floor(Double(month) / 8.0)).truncatingRemainder(dividingBy: 2))

        // if february
        if month == 2 {
            if calendarType == 1 || (calendarType == 0 && year > 1752) {
                if (year % 4 == 0 && year % 100 != 0) || year % 400 == 0 {
                    leap = 1
                }
            } else if year % 4 == 0 {
                leap = 1
            }
            mLen += leap - 2
        }

        if year == 1752 && month == 9 && calendarType == 0 {
            mLen = 19
        }

        return mLen
    }
}
