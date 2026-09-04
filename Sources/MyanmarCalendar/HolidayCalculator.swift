import Foundation

/// Holiday Calculator
/// The dates for holidays in Myanmar vary annually, contingent upon changes in the government.
/// Therefore, it is necessary to revise the calendar each year.
public struct HolidayCalculator {

    // Eid holidays (Julian day numbers)
    private static let GH_EID_2: [Int] = [2456936, 2457290, 2457644, 2457998, 2458353]

    // Chinese New Year holidays (Julian day numbers)
    private static let GH_CHINESE_NEW_YEAR: [Int] = [
        2456689, 2456690, 2457073, 2457074, 2457427, 2457428, 2457782,
        2457783, 2458166, 2458520, 2458874, 2459257, 2459612, 2459967, 2460351,
        2460705, 2461089, 2461443, 2461797, 2462181, 2462536
    ]

    // Diwali holidays (Julian day numbers)
    private static let GH_DIWALI: [Int] = [
        2456599, 2456953, 2457337, 2457691, 2458045, 2458430, 2458784, 2459168,
        2459523, 2459877
    ]

    // Eid holidays (Julian day numbers)
    private static let GH_EID: [Int] = [
        2456513, 2456867, 2457221, 2457576, 2457930, 2458285, 2458640, 2459063,
        2459416, 2459702, 2460125, 2460261
    ]

    // MARK: - English Holidays

    /// Check for English Holiday
    public static func englishHoliday(_ gy: Int, _ gm: Int, _ gd: Int) -> [String] {
        var holiday: [String] = []

        if (((gy >= 2018 && gy <= 2021) || gy >= 2025) && gm == 1 && gd == 1)
            || (gy == 2026 && gm == 1 && gd == 2) {
            holiday.append("New Year's Day")
        } else if gy >= 1948 && gm == 1 && gd == 4 {
            holiday.append("Independence Day")
        } else if gy >= 1947 && gm == 2 && gd == 12 {
            holiday.append("Union Day")
        } else if gy >= 1958 && gm == 3 && gd == 2 {
            holiday.append("Peasants' Day")
        } else if gy >= 1945 && gm == 3 && gd == 27 {
            holiday.append("Resistance Day")
        } else if gy >= 1923 && gm == 5 && gd == 1 {
            holiday.append("Labour Day")
        } else if gy >= 1947 && gm == 7 && gd == 19 {
            holiday.append("Martyrs' Day")
        } else if gm == 12 && gd == 25 {
            holiday.append("Christmas Day")
        } else if gy == 2017 && gm == 12 && gd == 30 {
            holiday.append("Holiday")
        } else if (gy >= 2017 && gy <= 2021) && gm == 12 && gd == 31 {
            holiday.append("Holiday")
        }

        return holiday
    }

    public static func continuousHoliday(_ gy: Int, _ gm: Int, _ gd: Int) -> [String] {
        var holiday: [String] = []

        // Update For 2024 and 2025 Calendar Year
        if (gy == 2024 && gm == 12 && gd == 31)
            || (gy == 2025 && gm == 3 && (gd == 12 || gd == 14))
            || (gy == 2025 && gm == 11 && gd == 3)
            || (gy == 2025 && gm == 12 && gd == 26)
            || (gy == 2026 && gm == 2 && gd == 13) {
            holiday.append("Holiday")
        }

        return holiday
    }

    // MARK: - Myanmar Holidays

    /// Check for Myanmar Holiday
    public static func myanmarHoliday(_ myear: Int, _ mmonth: Int, _ monthDay: Int, _ moonPhase: Int) -> [String] {
        var holiday: [String] = []

        if mmonth == 2 && moonPhase == 1 {
            holiday.append("Buddha Day")
        } else if mmonth == 4 && moonPhase == 1 {
            holiday.append("Start of Buddhist Lent")
        } else if mmonth == 7 && moonPhase == 1 {
            holiday.append("End of Buddhist Lent")
        } else if myear >= 1379 && mmonth == 7 && (monthDay == 14 || monthDay == 16) {
            holiday.append("Holiday")
        } else if mmonth == 8 && moonPhase == 1 {
            holiday.append("Tazaungdaing")
        } else if ((myear >= 1379 && myear <= 1385) || myear == 1388) && mmonth == 8 && monthDay == 14 {
            holiday.append("Holiday")
        } else if myear >= 1282 && mmonth == 8 && monthDay == 25 {
            holiday.append("National Day")
        } else if mmonth == 10 && monthDay == 1 {
            holiday.append("Karen New Year's Day")
        } else if mmonth == 12 && moonPhase == 1 {
            holiday.append("Tabaung Pwe")
        }

        return holiday
    }

    // MARK: - Thingyan

    /// Calculate Thingyan holidays
    public static func thingyan(_ jdn: Double, _ myear: Int, _ monthType: Int) -> [String] {
        let bgntg = 1100
        var holiday: [String] = []

        let ja = Constants.SY * Double(myear + monthType) + Constants.MO
        let jk: Double

        if myear >= Constants.SE3 {
            jk = ja - 2.169918982
        } else {
            jk = ja - 2.1675
        }

        let akn = jk.rounded()
        let atn = ja.rounded()

        if abs(jdn - (atn + 1)) < 0.0000001 {
            holiday.append("Myanmar New Year's Day")
        }

        if (myear + monthType) >= bgntg {
            if jdn == atn {
                holiday.append("Thingyan Atat")
            } else if jdn > akn && jdn < atn {
                holiday.append("Thingyan Akyat")
            } else if jdn == akn {
                holiday.append("Thingyan Akya")
            } else if jdn == (akn - 1) {
                holiday.append("Thingyan Akyo")
            } else if (myear + monthType) >= 1369 && (myear + monthType) < 1379
                        && (jdn == (akn - 2) || (jdn >= (atn + 2) && jdn <= (akn + 7))) {
                holiday.append("Holiday")
            } else if ((myear + monthType) >= 1384 && (myear + monthType) <= 1385)
                        && (jdn == (akn - 5) || jdn == (akn - 4) || jdn == (akn - 3) || jdn == (akn - 2)) {
                holiday.append("Holiday")
            } else if (myear + monthType) == 1386 && (jdn >= (atn + 2) && jdn <= (akn + 7)) {
                holiday.append("Holiday")
            } else if (myear + monthType) >= 1387 && (jdn >= (akn - 3) && jdn <= (akn + 5)) {
                holiday.append("Holiday")
            }
        }

        return holiday
    }

    // MARK: - Other Holidays

    /// Other holidays (Diwali, Eid, Chinese New Year)
    public static func otherHoliday(_ jd: Double) -> [String] {
        var holiday: [String] = []

        if BinarySearchUtil.search(jd, GH_DIWALI) >= 0 {
            holiday.append("Diwali")
        }
        if BinarySearchUtil.search(jd, GH_EID) >= 0 {
            holiday.append("Eid")
        }
        if jd > 2460677 && BinarySearchUtil.search(jd, GH_CHINESE_NEW_YEAR) >= 0 {
            holiday.append("Chinese New Year's")
        }
        // Chinese New Year Holiday Start from 2026
        if jd == 2461088 {
            holiday.append("Chinese New Year's")
        }

        return holiday
    }

    private static func getSubstituteHoliday(_ jd: Double) -> [String] {
        var holiday: [String] = []

        let substituteHoliday: [Int] = [
            // 2019
            2458768, 2458772, 2458785, 2458800,
            // 2020
            2458855, 2458918, 2458950, 2459051, 2459062,
            2459152, 2459156, 2459167, 2459181, 2459184,
            // 2021
            2459300, 2459303, 2459323, 2459324,
            2459335, 2459548, 2459573
        ]

        if BinarySearchUtil.search(jd, substituteHoliday) >= 0 {
            holiday.append("Holiday")
        }

        return holiday
    }

    // MARK: - Anniversary Days

    /// Calculate Date of Easter using "Meeus/Jones/Butcher" algorithm
    private static func dateOfEaster(_ year: Int) -> Double {
        let a = Double(year % 19)
        let b = floor(Double(year) / 100)
        let c = Double(year % 100)
        let d = floor(b / 4)
        let e = b.truncatingRemainder(dividingBy: 4)
        let f = floor((b + 8) / 25)
        let g = floor((b - f + 1) / 3)
        let h = (19 * a + b - d - g + 15).truncatingRemainder(dividingBy: 30)
        let i = floor(c / 4)
        let k = c.truncatingRemainder(dividingBy: 4)
        let l = (32 + 2 * e + 2 * i - h - k).truncatingRemainder(dividingBy: 7)
        let m = floor((a + 11 * h + 22 * l) / 451)
        let q = h + l - 7 * m + 114
        let day = Int(q.truncatingRemainder(dividingBy: 31) + 1)
        let month = Int(floor(q / 31))
        // this is for Gregorian
        return WesternDateKernel.westernToJulian(year, month, day, 1, 0)
    }

    /// Anniversary day
    private static func getAnniversaryDay(_ jd: Double, _ calendarType: CalendarType) -> [String] {
        var anniversary: [String] = []

        let wd = WesternDate.fromJulian(jd, calendarType: calendarType)
        let doe = dateOfEaster(wd.year)

        if wd.year <= 2017 && wd.month == 1 && wd.day == 1 {
            anniversary.append("New Year Day")
        } else if wd.year >= 1915 && wd.month == 2 && wd.day == 13 {
            anniversary.append("G. Aung San BD")
        } else if wd.year >= 1969 && wd.month == 2 && wd.day == 14 {
            anniversary.append("Valentines Day")
        } else if wd.year >= 1970 && wd.month == 4 && wd.day == 22 {
            anniversary.append("Earth Day")
        } else if wd.year >= 1392 && wd.month == 4 && wd.day == 1 {
            anniversary.append("April Fools' Day")
        } else if wd.year >= 1948 && wd.month == 5 && wd.day == 8 {
            anniversary.append("Red Cross Day")
        } else if wd.year >= 1994 && wd.month == 10 && wd.day == 5 {
            anniversary.append("World Teachers' Day")
        } else if wd.year >= 1947 && wd.month == 10 && wd.day == 24 {
            anniversary.append("United Nations Day")
        } else if wd.year >= 1753 && wd.month == 10 && wd.day == 31 {
            anniversary.append("Halloween")
        }

        if wd.year >= 1876 && jd == doe {
            anniversary.append("Easter")
        } else if wd.year >= 1876 && jd == (doe - 2) {
            anniversary.append("Good Friday")
        } else if BinarySearchUtil.search(jd, GH_EID_2) >= 0 {
            anniversary.append("Eid")
        }
        if BinarySearchUtil.search(jd, GH_CHINESE_NEW_YEAR) >= 0 {
            anniversary.append("Chinese New Year's")
        }

        return anniversary
    }

    /// Myanmar Anniversary day
    private static func getMyanmarAnniversaryDay(_ myear: Int, _ mmonth: Int, _ monthDay: Int, _ moonPhase: Int) -> [String] {
        var holiday: [String] = []

        if myear >= 1309 && mmonth == 11 && monthDay == 16 {
            holiday.append("'Mon' National Day")
        } else if mmonth == 9 && monthDay == 1 {
            holiday.append("Shan New Year's Day")
            if myear >= 1306 {
                holiday.append("Authors' Day")
            }
        } else if mmonth == 3 && moonPhase == 1 {
            holiday.append("Mahathamaya Day")
        } else if mmonth == 6 && moonPhase == 1 {
            holiday.append("Garudhamma Day")
        } else if myear >= 1356 && mmonth == 10 && moonPhase == 1 {
            holiday.append("Mothers' Day")
        } else if myear >= 1370 && mmonth == 12 && moonPhase == 1 {
            holiday.append("Fathers' Day")
        } else if mmonth == 5 && moonPhase == 1 {
            holiday.append("Metta Day")
        } else if mmonth == 5 && monthDay == 10 {
            holiday.append("Taungpyone Pwe")
        } else if mmonth == 5 && monthDay == 23 {
            holiday.append("Yadanagu Pwe")
        }

        return holiday
    }

    // MARK: - Public API

    /// Get holidays for a Myanmar date
    /// - Parameter myanmarDate: MyanmarDate object
    /// - Returns: List of holiday names
    public static func getHoliday(_ myanmarDate: MyanmarDate) -> [String] {
        return getHoliday(myanmarDate, Config.getInstance().language)
    }

    /// Get holidays for a Myanmar date with specified language
    /// - Parameters:
    ///   - myanmarDate: MyanmarDate object
    ///   - language: Target language
    /// - Returns: List of holiday names in specified language
    public static func getHoliday(_ myanmarDate: MyanmarDate, _ language: Language) -> [String] {
        return getHoliday(myanmarDate, Config.getInstance().calendarType, language)
    }

    /// Get holidays for a Myanmar date with calendar type and language
    /// - Parameters:
    ///   - myanmarDate: MyanmarDate object
    ///   - calendarType: Calendar type
    ///   - language: Target language
    /// - Returns: List of holiday names in specified language
    public static func getHoliday(_ myanmarDate: MyanmarDate, _ calendarType: CalendarType, _ language: Language) -> [String] {
        let westernDate = WesternDate.fromJulian(myanmarDate.jd, calendarType: calendarType)

        let hde = englishHoliday(westernDate.year, westernDate.month, westernDate.day)
        let hdm = myanmarHoliday(myanmarDate.myear, myanmarDate.mmonth, myanmarDate.monthDay, myanmarDate.moonPhase)
        let hdt = thingyan(myanmarDate.jd, myanmarDate.myear, myanmarDate.monthType)
        let hdo = otherHoliday(myanmarDate.jd)

        var holiday: [String] = []

        holiday.append(contentsOf: LanguageTranslator.translateSentenceList(hde, .english, language))
        holiday.append(contentsOf: LanguageTranslator.translateSentenceList(hdm, .english, language))
        holiday.append(contentsOf: LanguageTranslator.translateSentenceList(hdt, .english, language))
        holiday.append(contentsOf: LanguageTranslator.translateSentenceList(hdo, .english, language))

        if westernDate.year >= 2019 && westernDate.year <= 2021 {
            let substituteHoliday = getSubstituteHoliday(myanmarDate.jd)
            holiday.append(contentsOf: LanguageTranslator.translateSentenceList(substituteHoliday, .english, language))
        }

        if westernDate.year >= 2024 && westernDate.year <= 2026 {
            let continuousHoliday = continuousHoliday(westernDate.year, westernDate.month, westernDate.day)
            holiday.append(contentsOf: LanguageTranslator.translateSentenceList(continuousHoliday, .english, language))
        }

        return holiday
    }

    /// Check if a date is a holiday
    /// - Parameter myanmarDate: MyanmarDate object
    /// - Returns: true if the date is a holiday
    public static func isHoliday(_ myanmarDate: MyanmarDate) -> Bool {
        return !getHoliday(myanmarDate).isEmpty
    }

    /// Get anniversaries for a Myanmar date
    /// - Parameter myanmarDate: MyanmarDate object
    /// - Returns: List of anniversary names
    public static func getAnniversary(_ myanmarDate: MyanmarDate) -> [String] {
        return getAnniversary(myanmarDate, Config.getInstance().calendarType, Config.getInstance().language)
    }

    /// Get anniversaries for a Myanmar date with language
    /// - Parameters:
    ///   - myanmarDate: MyanmarDate object
    ///   - language: Target language
    /// - Returns: List of anniversary names in specified language
    public static func getAnniversary(_ myanmarDate: MyanmarDate, _ language: Language) -> [String] {
        return getAnniversary(myanmarDate, Config.getInstance().calendarType, language)
    }

    /// Get anniversaries for a Myanmar date with calendar type and language
    /// - Parameters:
    ///   - myanmarDate: MyanmarDate object
    ///   - calendarType: Calendar type
    ///   - language: Target language
    /// - Returns: List of anniversary names in specified language
    public static func getAnniversary(_ myanmarDate: MyanmarDate, _ calendarType: CalendarType, _ language: Language) -> [String] {
        let ecd = getAnniversaryDay(myanmarDate.jd, calendarType)
        let mcd = getMyanmarAnniversaryDay(myanmarDate.myear, myanmarDate.mmonth, myanmarDate.monthDay, myanmarDate.moonPhase)

        var anniversary: [String] = []

        anniversary.append(contentsOf: LanguageTranslator.translateSentenceList(ecd, .english, language))
        anniversary.append(contentsOf: LanguageTranslator.translateSentenceList(mcd, .english, language))

        return anniversary
    }
}
