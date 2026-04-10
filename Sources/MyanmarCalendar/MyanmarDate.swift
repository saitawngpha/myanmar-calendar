import Foundation

/// Myanmar Date
public struct MyanmarDate {

    /// Myanmar year
    public let myear: Int

    /// Year type [0=common, 1=little watat, 2=big watat]
    public let yearType: Int

    /// Year length [normal = 354, small watat = 384, or big watat = 385 days]
    public let yearLength: Int

    /// Month (Tagu=1, Kason=2, Nayon=3, 1st Waso=0, (2nd) Waso=4, Wagaung=5,
    /// Tawthalin=6, Thadingyut=7, Tazaungmon=8, Nadaw=9, Pyatho=10, Tabodwe=11, Tabaung=12)
    public let mmonth: Int

    /// Month type [1=hnaung, 0= Oo]
    public let monthType: Int

    /// Month length [29 or 30 days]
    public let monthLength: Int

    /// Day of month [1 to 30]
    public let monthDay: Int

    /// Moon phase [0=waxing, 1=full moon, 2=waning, 3=new moon]
    public let moonPhase: Int

    /// Fortnight day [1 to 15]
    public let fortnightDay: Int

    /// Week day [0=sat, 1=sun, ..., 6=fri]
    public let weekDay: Int

    /// Julian day number
    public let jd: Double

    internal init(myear: Int, yearType: Int, yearLength: Int, mmonth: Int, monthType: Int,
                  monthLength: Int, monthDay: Int, moonPhase: Int, fortnightDay: Int,
                  weekDay: Int, jd: Double) {
        self.myear = myear
        self.yearType = yearType
        self.yearLength = yearLength
        self.mmonth = mmonth
        self.monthType = monthType
        self.monthLength = monthLength
        self.monthDay = monthDay
        self.moonPhase = moonPhase
        self.fortnightDay = fortnightDay
        self.weekDay = weekDay
        self.jd = jd
    }

    // MARK: - Factory Methods

    /// Create Myanmar Date from myanmar year, month and day
    /// - Parameters:
    ///   - myear: Myanmar Year (2 to 1500)
    ///   - mmonth: Myanmar month [Tagu=1, Kason=2, Nayon=3, 1st Waso=0, (2nd) Waso=4, etc.]
    ///   - monthDay: day of month [from 1 to 29 or 30]
    /// - Returns: Myanmar date
    public static func create(myear: Int, mmonth: Int, monthDay: Int) throws -> MyanmarDate {
        let jd = Double(MyanmarDateKernel.myanmarDateToJulian(myear, mmonth, monthDay))
        return try MyanmarDateKernel.julianToMyanmarDate(jd)
    }

    /// Create Myanmar Date from myanmar year, month name and day
    public static func create(myear: Int, myanmarMonthName: String, monthDay: Int) throws -> MyanmarDate {
        let jd = try MyanmarDateKernel.getJulianDayNumber(myear, myanmarMonthName, monthDay)
        return try MyanmarDateKernel.julianToMyanmarDate(jd)
    }

    /// Create Myanmar Date from current date and time
    public static func now() throws -> MyanmarDate {
        return try of(Date())
    }

    /// Create Myanmar Date from Foundation Date
    public static func of(_ date: Date) throws -> MyanmarDate {
        let calendar = Calendar.current
        let components = calendar.dateComponents(in: TimeZone(identifier: Constants.MYANMAR_ZONE_ID) ?? TimeZone.current, from: date)
        return try of(
            year: components.year ?? 0,
            month: components.month ?? 0,
            day: components.day ?? 0,
            hour: components.hour ?? 0,
            minute: components.minute ?? 0,
            second: components.second ?? 0
        )
    }

    /// Create Myanmar Date from Western date
    /// - Parameters:
    ///   - year: Western Year
    ///   - month: Western Month [1 = Jan, ... , 12 = Dec]
    ///   - day: Western Day [1-31]
    /// - Returns: Myanmar date
    public static func of(year: Int, month: Int, day: Int) throws -> MyanmarDate {
        return try of(year: year, month: month, day: day, calendarType: Config.getInstance().calendarType, sg: 0)
    }

    /// Create Myanmar Date from Western date with time
    public static func of(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) throws -> MyanmarDate {
        return try of(year: year, month: month, day: day, hour: hour, minute: minute, second: second, calendarType: Config.getInstance().calendarType, sg: 0)
    }

    /// Create Myanmar Date from Western date with calendar type
    public static func of(year: Int, month: Int, day: Int, calendarType: CalendarType, sg: Double) throws -> MyanmarDate {
        let julianDayNumber = WesternDateKernel.westernToJulian(year, month, day, calendarType, sg)
        return try of(julianDayNumber: julianDayNumber)
    }

    /// Create Myanmar Date from Western date with time and calendar type
    public static func of(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int, calendarType: CalendarType, sg: Double) throws -> MyanmarDate {
        let julianDayNumber = WesternDateKernel.westernToJulian(year, month, day, hour, minute, second, calendarType, sg)
        return try of(julianDayNumber: julianDayNumber)
    }

    /// Create Myanmar Date from Julian day number
    public static func of(julianDayNumber: Double) throws -> MyanmarDate {
        return try MyanmarDateKernel.julianToMyanmarDate(julianDayNumber)
    }

    // MARK: - Getters

    /// Get Buddhist Era value
    public func getBuddhistEraValue() -> Int {
        let buddhistEraOffset = (mmonth == 1 || (mmonth == 2 && monthDay < 16)) ? 1181 : 1182
        return myear + buddhistEraOffset
    }

    /// Get Buddhist Era as string in the specified language
    public func getBuddhistEra(_ language: Language = Config.getInstance().language) -> String {
        return LanguageTranslator.translate(getBuddhistEraValue(), language)
    }

    /// Get Myanmar year value
    public func getYearValue() -> Int {
        return myear
    }

    /// Get Myanmar year as string in the specified language
    public func getYear(_ language: Language = Config.getInstance().language) -> String {
        return LanguageTranslator.translate(myear, language)
    }

    /// Get month name
    public func getMonthName(_ language: Language = Config.getInstance().language) -> String {
        var result = ""

        if mmonth == 4 && yearType > 0 {
            result += LanguageTranslator.translate("Second", language) + " "
        }

        result += LanguageTranslator.translateSentence(Constants.EMA[mmonth], .english, language)
        return result
    }

    /// Get month number
    public func getMonth() -> Int {
        return mmonth
    }

    /// Get moon phase value [0=waxing, 1=full moon, 2=waning, 3=new moon]
    public func getMoonPhaseValue() -> Int {
        return moonPhase
    }

    /// Get moon phase as string
    public func getMoonPhase(_ language: Language = Config.getInstance().language) -> String {
        return LanguageTranslator.translateSentence(Constants.MSA[moonPhase], .english, language)
    }

    /// Get fortnight day value [1 to 15]
    public func getFortnightDay(_ language: Language = Config.getInstance().language) -> String {
        return LanguageTranslator.translate(fortnightDay, language)
    }

    /// Get weekday name
    public func getWeekDay(_ language: Language = Config.getInstance().language) -> String {
        return LanguageTranslator.translateSentence(Constants.WDA[weekDay], .english, language)
    }

    /// Get weekday value [0=sat, 1=sun, ..., 6=fri]
    public func getWeekDayValue() -> Int {
        return weekDay
    }

    /// Get day of month value [1-30]
    public func getDayOfMonth() -> Int {
        return monthDay
    }

    /// Get Julian Day Number
    public func getJulianDayNumber() -> Double {
        return jd
    }

    /// Convert to WesternDate
    public func toWesternDate(calendarType: CalendarType = .english) -> WesternDate {
        return WesternDateKernel.julianToWestern(jd, calendarType)
    }

    /// Convert to Foundation Date
    public func toDate() -> Date? {
        return toWesternDate().toDate()
    }

    // MARK: - Formatting

    /// Format Myanmar date with pattern
    /// Pattern letters:
    /// S = Sasana year, s = Buddhist era, B = Burmese year, y = Myanmar year,
    /// k = Ku, M = Month, p = Moon phase, f = Fortnight Day, r = Yat, E = Day name, n = Nay
    public func format(_ pattern: String, _ language: Language = Config.getInstance().language) -> String {
            var result = ""

            let replacements: [Character: String] = [
                "S": LanguageTranslator.translate("Sasana Year", language),
                "s": getBuddhistEra(language),
                "B": LanguageTranslator.translate("Myanmar Year", language),
                "y": getYear(language),
                "k": LanguageTranslator.translate("Ku", language),
                "M": getMonthName(language),
                "p": getMoonPhase(language),
                "f": getFortnightDay(language),
                "r": LanguageTranslator.translate("Yat", language),
                "E": getWeekDay(language),
                "n": LanguageTranslator.translate("Nay", language)
            ]

            for char in pattern {
                if let replacement = replacements[char] {
                    result += replacement
                } else {
                    result.append(char)
                }
            }

            return result
        }
//    public func format(_ pattern: String, _ language: Language = Config.getInstance().language) -> String {
//        var result = pattern
//
//        let replacements: [(String, String)] = [
//            ("S", LanguageTranslator.translate("Sasana Year", language)),
//            ("s", getBuddhistEra(language)),
//            ("B", LanguageTranslator.translate("Myanmar Year", language)),
//            ("y", getYear(language)),
//            ("k", LanguageTranslator.translate("Ku", language)),
//            ("M", getMonthName(language)),
//            ("p", getMoonPhase(language)),
//            ("f", getFortnightDay(language)),
//            ("r", LanguageTranslator.translate("Yat", language)),
//            ("E", getWeekDay(language)),
//            ("n", LanguageTranslator.translate("Nay", language))
//        ]
//
//        for (pattern, replacement) in replacements {
//            result = result.replacingOccurrences(of: pattern, with: replacement)
//        }
//
//        return result
//    }
}

extension MyanmarDate: CustomStringConvertible {
    public var description: String {
        return "Myanmar Year: \(myear), Month: \(getMonthName()), Day: \(monthDay), Weekday: \(getWeekDay())"
    }
}

extension MyanmarDate: Equatable {
    public static func == (lhs: MyanmarDate, rhs: MyanmarDate) -> Bool {
        return lhs.jd == rhs.jd
    }
}
