import Foundation

/// Calculation Algorithms for Myanmar Astro
public struct AstroKernel {

    private init() {}

    /// Calculate thamaphyu
    public static func calculateThamaphyu(_ md: Int, _ weekDay: Int) -> Int {
        let mf = MyanmarCalendarKernel.calculateFortnightDay(md)
        let wda = [1, 2, 6, 6, 5, 6, 7]
        let wdb = [0, 1, 0, 0, 0, 3, 3]
        return (mf == wda[weekDay] || mf == wdb[weekDay] || (mf == 4 && weekDay == 5)) ? 1 : 0
    }

    /// nagapor
    public static func calculateNagapor(_ md: Int, _ weekDay: Int) -> Int {
        let wda = [26, 21, 2, 10, 18, 2, 21]
        let wdb = [17, 19, 1, 0, 9, 0, 0]

        return (md == wda[weekDay] ||
                md == wdb[weekDay] ||
                (md == 2 && weekDay == 1) ||
                ((md == 12 || md == 4 || md == 18) && weekDay == 2)) ? 1 : 0
    }

    /// yatyotema
    public static func calculateYatyotema(_ mmonth: Int, _ md: Int) -> Int {
        var adjustedMonth = mmonth
        let mmt = adjustedMonth / 13
        adjustedMonth = adjustedMonth % 13 + mmt
        if adjustedMonth <= 0 {
            adjustedMonth = 4
        }

        let mf = MyanmarCalendarKernel.calculateFortnightDay(md)
        var m1 = (adjustedMonth % 2 != 0) ? adjustedMonth : (adjustedMonth + 9) % 12
        m1 = (m1 + 4) % 12 + 1
        return (mf == m1) ? 1 : 0
    }

    /// mahayatkyan
    public static func calculateMahayatkyan(_ mmonth: Int, _ md: Int) -> Int {
        var adjustedMonth = mmonth
        if adjustedMonth <= 0 {
            adjustedMonth = 4
        }

        let mf = MyanmarCalendarKernel.calculateFortnightDay(md)
        let m1 = ((adjustedMonth % 12) / 2) + 4
        let result = m1 % 6 + 1
        return (mf == result) ? 1 : 0
    }

    /// shanyat
    public static func calculateShanyat(_ mmonth: Int, _ md: Int) -> Int {
        var adjustedMonth = mmonth
        let mmt = adjustedMonth / 13
        adjustedMonth = adjustedMonth % 13 + mmt
        if adjustedMonth <= 0 {
            adjustedMonth = 4
        }

        let mf = MyanmarCalendarKernel.calculateFortnightDay(md)
        let sya = [8, 8, 2, 2, 9, 3, 3, 5, 1, 4, 7, 4]
        return (mf == sya[adjustedMonth - 1]) ? 1 : 0
    }

    /// Calculate sabbath day and sabbath eve
    public static func calculateSabbath(_ yearType: Int, _ mmonth: Int, _ md: Int) -> Int {
        let mml = MyanmarCalendarKernel.calculateLengthOfMonth(mmonth, yearType)
        var sabbath = 0

        if md == 8 || md == 15 || md == 23 || md == mml {
            sabbath = 1
        }

        if md == 7 || md == 14 || md == 22 || md == (mml - 1) {
            sabbath = 2
        }

        return sabbath
    }

    /// Calculate yatyaza from month, and weekday
    public static func calculateYatyaza(_ mm: Int, _ weekDay: Int) -> Int {
        let m1 = mm % 4
        var yatyaza = 0
        let wd1 = (m1 / 2) + 4
        let wd2 = ((1 - (m1 / 2)) + m1 % 2) * (1 + 2 * (m1 % 2))

        if weekDay == wd1 || weekDay == wd2 {
            yatyaza = 1
        }

        return yatyaza
    }

    /// Calculate pyathada from month, and weekday
    public static func calculatePyathada(_ mmonth: Int, _ weekDay: Int) -> Int {
        let m1 = mmonth % 4
        let wda = [1, 3, 3, 0, 2, 1, 2]

        var pyathada = 0

        if m1 == wda[weekDay] {
            pyathada = 1
        }

        if m1 == 0 && weekDay == 4 {
            pyathada = 2 // afternoon pyathada
        }

        return pyathada
    }

    /// Calculate nagahle from Myanmar month
    public static func calculateNagahle(_ mmonth: Int) -> Int {
        var adjustedMonth = mmonth
        if adjustedMonth <= 0 {
            adjustedMonth = 4
        }
        return (adjustedMonth % 12) / 3
    }

    /// mahabote
    public static func calculateMahabote(_ myear: Int, _ weekDay: Int) -> Int {
        return (myear - weekDay) % 7
    }

    /// nakhat
    public static func calculateNakhat(_ myear: Int) -> Int {
        return myear % 3
    }

    /// thamanyo
    public static func calculateThamanyo(_ mmonth: Int, _ weekDay: Int) -> Int {
        var adjustedMonth = mmonth
        let mmt = adjustedMonth / 13
        adjustedMonth = adjustedMonth % 13 + mmt

        if adjustedMonth <= 0 {
            adjustedMonth = 4
        }

        let m1 = adjustedMonth - 1 - (adjustedMonth / 9)
        let wd1 = (m1 * 2 - (m1 / 8)) % 7
        let wd2 = (weekDay + 7 - wd1) % 7

        return (wd2 <= 1) ? 1 : 0
    }

    /// amyeittasote
    public static func calculateAmyeittasote(_ md: Int, _ weekDay: Int) -> Int {
        let mf = MyanmarCalendarKernel.calculateFortnightDay(md)
        let wda = [5, 8, 3, 7, 2, 4, 1]
        return (mf == wda[weekDay]) ? 1 : 0
    }

    /// warameittugyi
    public static func calculateWarameittugyi(_ md: Int, _ weekDay: Int) -> Int {
        let mf = MyanmarCalendarKernel.calculateFortnightDay(md)
        let wda = [7, 1, 4, 8, 9, 6, 3]
        return (mf == wda[weekDay]) ? 1 : 0
    }

    /// warameittunge
    public static func calculateWarameittunge(_ md: Int, _ weekDay: Int) -> Int {
        let mf = MyanmarCalendarKernel.calculateFortnightDay(md)
        let wn = (weekDay + 6) % 7
        return ((12 - mf) == wn) ? 1 : 0
    }

    /// yatpote
    public static func calculateYatpote(_ md: Int, _ wd: Int) -> Int {
        let mf = MyanmarCalendarKernel.calculateFortnightDay(md)
        let wda = [8, 1, 4, 6, 9, 8, 7]
        return (mf == wda[wd]) ? 1 : 0
    }

    /// Calculate year name
    public static func calculateYearName(_ myear: Int) -> Int {
        return myear % 12
    }
}
