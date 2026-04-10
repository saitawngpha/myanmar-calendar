import Foundation

/// Myanmar Calendar Kernel - Core calculations and utilities
public struct MyanmarCalendarKernel {

    /// Calculate related Myanmar month names by year
    /// - Parameters:
    ///   - myear: Myanmar Year
    ///   - mmonth: Myanmar month [Tagu=1, Kason=2, Nayon=3, 1st Waso=0, (2nd) Waso=4, etc.]
    /// - Returns: MyanmarMonths object
    public static func calculateRelatedMyanmarMonths(_ myear: Int, _ mmonth: Int) throws -> MyanmarMonths {

        let j1 = (Constants.SY * Double(myear) + Constants.MO).rounded() + 1.0
        let j2 = (Constants.SY * Double(myear + 1) + Constants.MO).rounded()

        // myanmar year start date
        let m1 = try MyanmarDateKernel.julianToMyanmarDate(j1)
        // myanmar year-end date
        let m2 = try MyanmarDateKernel.julianToMyanmarDate(j2)

        var si = m1.mmonth
        let ei = m2.mmonth

        if si == 0 {
            si = 4 // si will always Tagu or Kason
        }

        var adjustedMonth = mmonth
        // in case 1st Waso, start at Waso which will take care in the for loop later
        if adjustedMonth == 0 && m1.yearType == 0 {
            // if non watat year and 1st waso is selected
            adjustedMonth = 4
        }
        if adjustedMonth != 0 && adjustedMonth < si {
            // if the year start at Kason and tagu is selected
            adjustedMonth = si
        }
        if adjustedMonth > ei {
            // if the year-end at late tagu and late Kason is selected
            adjustedMonth = ei
        }

        return populateMonthLists(m1.yearType, si, ei, adjustedMonth)
    }

    private static func populateMonthLists(_ yearType: Int, _ si: Int, _ ei: Int, _ mmonth: Int) -> MyanmarMonths {
        var monthList: [Int] = []
        var monthNameList: [String] = []
        var currentIndex = 0

        for i in si...ei {
            if i == 4 && yearType != 0 {
                monthList.append(0)
                monthNameList.append(Constants.EMA[0])
                if mmonth == 0 {
                    currentIndex = 0
                }
            }

            monthList.append(i)
            monthNameList.append(((i == 4 && yearType != 0) ? "Second " : "") + Constants.EMA[i])

            if i == mmonth {
                currentIndex = i
            }
        }

        return MyanmarMonths(monthList: monthList, monthNameList: monthNameList, calculationMonth: currentIndex)
    }

    /// Western Calendar Title for month
    /// - Parameters:
    ///   - year: Western Year
    ///   - month: Western Month [1 = Jan, ... , 12 = Dec]
    ///   - language: Language (optional)
    /// - Returns: Calendar Title for month
    public static func getCalendarHeaderForWesternStyle(_ year: Int, _ month: Int, _ language: Language = Config.getInstance().language) throws -> String {
        let monthLength = WesternDateKernel.getLengthOfMonth(year, month, Config.getInstance().calendarType.number)
        let startDate = try MyanmarDate.of(year: year, month: month, day: 1)
        let je = startDate.jd + Double(monthLength) - 1
        let endDate = try MyanmarDate.of(julianDayNumber: je)
        return getCalendarHeader(startDate, endDate, language)
    }

    /// Calendar Title for month
    /// - Parameters:
    ///   - myear: Myanmar Year
    ///   - mmonth: Myanmar month
    ///   - language: Language (optional)
    /// - Returns: Calendar Title for month
    public static func getCalendarHeader(_ myear: Int, _ mmonth: Int, _ language: Language = Config.getInstance().language) throws -> String {
        return try getCalendarHeader(myear, mmonth, 1, language)
    }

    /// Calendar Title for month
    /// - Parameters:
    ///   - myear: Myanmar Year
    ///   - mmonth: Myanmar month
    ///   - mday: day of month [from 1 to 29 or 30]
    ///   - language: Language
    /// - Returns: Calendar Title for month
    public static func getCalendarHeader(_ myear: Int, _ mmonth: Int, _ mday: Int, _ language: Language) throws -> String {
        let julianDate = Double(MyanmarDateKernel.myanmarDateToJulian(myear, mmonth, mday))
        let myanmarDate = try MyanmarDate.of(julianDayNumber: julianDate)

        let js = myanmarDate.jd
        let eml = myanmarDate.monthLength
        let je = js + Double(eml) - 1

        let endMyanmarDate = try MyanmarDate.of(julianDayNumber: je)

        return getCalendarHeader(myanmarDate, endMyanmarDate, language)
    }

    private static func getCalendarHeader(_ startDateOfMonth: MyanmarDate, _ endDateOfMonth: MyanmarDate, _ language: Language) -> String {
        var str = ""

        str += getHeaderForBuddhistEra(startDateOfMonth, endDateOfMonth, language)

        if endDateOfMonth.myear >= 2 {
            str += language.punctuationMark
            str += getHeaderForMyanmarYear(startDateOfMonth, endDateOfMonth, language)
            str += language.punctuationMark
            str += getHeaderForMyanmarMonth(startDateOfMonth, endDateOfMonth, language)
        }

        return str
    }

    public static func getHeaderForBuddhistEra(_ startDate: MyanmarDate, _ endDate: MyanmarDate, _ language: Language) -> String {
        var result = ""

        result += LanguageTranslator.translate("Sasana Year", language)
        result += " "
        result += startDate.getBuddhistEra(language)

        if startDate.getBuddhistEraValue() != endDate.getBuddhistEraValue() {
            result += " - "
            result += endDate.getBuddhistEra(language)
        }

        result += " "
        result += LanguageTranslator.translate("Ku", language)

        return result
    }

    public static func getHeaderForMyanmarYear(_ startDateOfMonth: MyanmarDate, _ endDateOfMonth: MyanmarDate, _ language: Language) -> String {
        var result = ""

        result += LanguageTranslator.translate("Myanmar Year", language)
        result += " "

        if startDateOfMonth.myear >= 2 {
            result += startDateOfMonth.getYear(language)
            if startDateOfMonth.myear != endDateOfMonth.myear {
                result += " - "
            }
        }

        if startDateOfMonth.myear != endDateOfMonth.myear {
            result += endDateOfMonth.getYear(language)
        }

        result += " "
        result += LanguageTranslator.translate("Ku", language)

        return result
    }

    public static func getHeaderForMyanmarMonth(_ startDateOfMonth: MyanmarDate, _ endDateOfMonth: MyanmarDate, _ language: Language) -> String {
        var result = ""

        if startDateOfMonth.myear >= 2 {
            result += startDateOfMonth.getMonthName(language)
            if startDateOfMonth.mmonth != endDateOfMonth.mmonth {
                result += " - "
            }
        }

        if startDateOfMonth.mmonth != endDateOfMonth.mmonth {
            result += endDateOfMonth.getMonthName(language)
        }

        return result
    }

    /// Calculate the Myanmar Year Type
    /// - Parameter myear: Myanmar Year
    /// - Returns: Myanmar year type [0=common, 1=little watat, 2=big watat]
    public static func calculateYearType(_ myear: Int) -> Int {
        return MyanmarDateKernel.checkMyanmarYear(myear)["myt"]!
    }

    /// Calculate length of month from month, and year type
    /// - Parameters:
    ///   - mm: month
    ///   - myt: year type [0=common, 1=little watat, 2=big watat]
    /// - Returns: length of the month [29 or 30 days]
    public static func calculateLengthOfMonth(_ mm: Int, _ myt: Int) -> Int {
        var mml = 30 - mm % 2
        if mm == 3 {
            // adjust if Nayon in big watat
            mml += myt / 2
        }
        return mml
    }

    /// Calculate moon phase from day of the month, month, and year type
    /// - Parameters:
    ///   - myt: year type
    ///   - mm: month
    ///   - md: the day of the month [1-30]
    /// - Returns: moon phase [0 = waxing, 1 = full moon, 2 = waning, 3 = new moon]
    public static func calculateMoonPhase(_ myt: Int, _ mm: Int, _ md: Int) -> Int {
        let mml = calculateLengthOfMonth(mm, myt)
        let d = md / mml
        return Int(floor(Double(md + 1) / 16.0) + floor(Double(md) / 16.0)) + d
    }

    /// Calculates the apparent length of the year from year type
    /// - Parameter myt: year type [0=common, 1=little watat, 2=big watat]
    /// - Returns: year length [354, 384, or 385 days]
    public static func calculateMyanmarYearLength(_ myt: Int) -> Int {
        return 354 + (1 - Int(floor(1.0 / Double(myt + 1)))) * 30 + Int(floor(Double(myt) / 2.0))
    }

    /// Calculates fortnight day from month day
    /// - Parameter md: day of the month [1-30]
    /// - Returns: fortnight day [1 to 15]
    public static func calculateFortnightDay(_ md: Int) -> Int {
        return md - 15 * (md / 16)
    }

    /// Calculates day of month from fortnight day, moon phase, and length of the month
    /// - Parameters:
    ///   - myt: year type
    ///   - mm: month
    ///   - mp: moon phase [0=waxing, 1=full moon, 2=waning, 3=new moon]
    ///   - mf: fortnight day [1 to 15]
    /// - Returns: day of the month [1 - 30]
    public static func calculateDayOfMonthByYearType(_ myt: Int, _ mm: Int, _ mp: Int, _ mf: Int) -> Int {
        let mml = calculateLengthOfMonth(mm, myt)
        let m1 = mp % 2
        let m2 = mp / 2
        return m1 * (15 + m2 * (mml - 15)) + (1 - m1) * (mf + 15 * m2)
    }

    /// Get day of month from myanmar year, length of the month, moon phase and fortnight day
    /// - Parameters:
    ///   - myear: Myanmar Year
    ///   - mmonth: month
    ///   - moonPhase: moon phase [0=waxing, 1=full moon, 2=waning, 3=new moon]
    ///   - fortnightDay: fortnight day [1 to 15]
    /// - Returns: day of the month [1 - 30]
    public static func calculateDayOfMonth(_ myear: Int, _ mmonth: Int, _ moonPhase: Int, _ fortnightDay: Int) -> Int {
        // check year
        let yo = MyanmarDateKernel.checkMyanmarYear(myear)

        // adjust month and month length
        var mml = 30 - mmonth % 2

        if mmonth == 3 {
            // adjust if Nayon in big watat
            mml += yo["myt"]! / 2
        }

        let m1 = moonPhase % 2
        let m2 = moonPhase / 2

        return m1 * (15 + m2 * (mml - 15)) + (1 - m1) * (fortnightDay + 15 * m2)
    }
}
