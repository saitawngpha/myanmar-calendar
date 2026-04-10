import Foundation

/// Core Calculation and Algorithms for Myanmar Date
struct MyanmarDateKernel {

    enum MyanmarDateError: Error {
        case invalidJulianDayNumber(String)
        case invalidMonthName(String)
    }

    /// Year type enumeration
    enum YearType: Int {
        case common = 0
        case littleWatat = 1
        case bigWatat = 2
    }

    /// Julian day number to Myanmar date
    /// - Parameter jd: julian day number
    /// - Returns: MyanmarDate Object representing the converted date
    /// - Throws: MyanmarDateError if the Julian day number is invalid
    static func julianToMyanmarDate(_ jd: Double) throws -> MyanmarDate {

        guard jd >= 0 else {
            throw MyanmarDateError.invalidJulianDayNumber("Julian day number cannot be negative.")
        }

        var dd: Int

        let a: Int
        let b: Int
        let c: Int
        let e: Int
        let f: Int
        var mmonth: Int
        var monthDay: Int
        var monthLength: Int
        let moonPhase: Int
        let fortnightDay: Int
        let weekDay: Int

        // convert jd to jdn
        let jdn = Int(jd.rounded())
        // Myanmar year
        let myear = calculateMyanmarYear(jdn)
        // check year
        let yearInfo = checkMyanmarYear(myear)
        // day count
        dd = jdn - yearInfo["tg1"]! + 1
        b = yearInfo["myt"]! / 2
        // big wa and common yr
        c = 1 / (yearInfo["myt"]! + 1)
        // year length
        let yearLength = 354 + (1 - c) * 30 + b
        // month type: Hnaung =1 or Oo = 0 | late =1 or early = 0
        let monthType = (dd - 1) / yearLength
        dd -= monthType * yearLength
        // adjust day count and threshold
        a = (dd + 423) / 512
        // month
        mmonth = Int(floor((Double(dd - b * a + c * a * 30) + 29.26) / 29.544))
        e = (mmonth + 12) / 16
        f = (mmonth + 11) / 16
        // day of month
        monthDay = dd - Int(floor(29.544 * Double(mmonth) - 29.26)) - b * e + c * f * 30
        // adjust month numbers for late months
        mmonth += f * 3 - e * 4 + 12 * monthType
        // adjust month and month length
        monthLength = 30 - mmonth % 2

        if mmonth == 3 {
            // adjust if Nayon in big watat
            monthLength += yearInfo["myt"]! / 2
        }

        // moon phase from day of the month, month, and year type
        // [0=waxing, 1=full moon, 2=waning, 3=new moon]
        moonPhase = ((monthDay + 1) / 16) + (monthDay / 16) + (monthDay / monthLength)

        // fortnight day from month day
        // waxing or waning day
        fortnightDay = monthDay - 15 * (monthDay / 16)
        // week day
        weekDay = (jdn + 2) % 7

        return MyanmarDate(
            myear: myear,
            yearType: yearInfo["myt"]!,
            yearLength: yearLength,
            mmonth: mmonth,
            monthType: monthType,
            monthLength: monthLength,
            monthDay: monthDay,
            moonPhase: moonPhase,
            fortnightDay: fortnightDay,
            weekDay: weekDay,
            jd: jd
        )
    }

    private static func calculateMyanmarYear(_ jdn: Int) -> Int {
        return Int(floor((Double(jdn) - 0.5 - Constants.MO) / Constants.SY))
    }

    /// Check Myanmar Year (chk_my)
    /// - Parameter myear: myanmar year
    /// - Returns: Dictionary containing:
    ///   - myt: year type [0=common, 1=little watat, 2=big watat]
    ///   - tg1: the 1st day of Tagu as Julian Day Number
    ///   - fm: full moon day of [2nd] Waso as Julian Day Number
    ///   - werr: [0=ok, 1= error]
    static func checkMyanmarYear(_ myear: Int) -> [String: Int] {

        let y2 = checkWatat(myear)
        var myt = y2["watat"]!

        var yd = 0

        var y1: [String: Int]
        repeat {
            yd += 1
            y1 = checkWatat(myear - yd)
        } while y1["watat"]! == 0 && yd < 3

        let fm: Int
        var werr = 0

        if myt > 0 {
            let nd = Double(y2["fm"]! - y1["fm"]!).truncatingRemainder(dividingBy: 354)
            myt = Int(floor(nd / 31)) + 1
            fm = y2["fm"]!
            if nd != 30 && nd != 31 {
                werr = 1
            }
        } else {
            fm = y1["fm"]! + 354 * yd
        }

        let tg1 = y1["fm"]! + 354 * yd - 102

        return [
            "myt": myt,
            "tg1": tg1,
            "fm": fm,
            "werr": werr
        ]
    }

    /// Check watat (intercalary month)
    /// - Parameter my: myanmar year
    /// - Returns: Dictionary containing:
    ///   - watat: intercalary month [1=watat, 0=common]
    ///   - fm: full moon day of 2nd Waso in jdn_mm (only valid when watat=1)
    static func checkWatat(_ my: Int) -> [String: Int] {

        // get constants for the corresponding calendar era
        let c = MyanmarYearConstants.getMyConst(my)

        // threshold to adjust
        let threshold = (Constants.SY / 12 - Constants.LM) * (12 - c["NM"]!)
        // excess day
        var ed = (Constants.SY * Double(my + 3739)).truncatingRemainder(dividingBy: Constants.LM)

        if ed < threshold {
            // adjust excess days
            ed += Constants.LM
        }

        // full moon day of 2nd Waso
        let fm = Int((Constants.SY * Double(my) + Constants.MO - ed + 4.5 * Constants.LM + c["WO"]!).rounded())

        var watat = 0

        // find watat
        if c["EI"]! >= 2 {
            // if 2nd era or later find watat based on excess days
            let tw = Constants.LM - (Constants.SY / 12 - Constants.LM) * c["NM"]!

            if ed >= tw {
                watat = 1
            }
        } else {
            // if 1st era, find watat by 19 years metonic cycle
            var watatTemp = (my * 7 + 2) % 19
            if watatTemp < 0 {
                watatTemp += 19
            }
            watat = Int(floor(Double(watatTemp) / 12.0))
        }
        // correct watat exceptions
        watat ^= Int(c["EW"]!)

        return [
            "fm": fm,
            "watat": watat
        ]
    }

    /// Myanmar date to Julian date
    /// - Parameters:
    ///   - myear: Myanmar Year
    ///   - mmonth: Myanmar month [Tagu=1, Kason=2, Nayon=3, 1st Waso=0, (2nd) Waso=4, Wagaung=5, Tawthalin=6, Thadingyut=7, Tazaungmon=8, Nadaw=9, Pyatho=10, Tabodwe=11, Tabaung=12, Late Tagu=13, Late Kason=14]
    ///   - mmday: Myanmar's day of month [1 to 29 or 30]
    /// - Returns: julian day number
    static func myanmarDateToJulian(_ myear: Int, _ mmonth: Int, _ mmday: Int) -> Int {

        let yo = checkMyanmarYear(myear)

        let mmt = mmonth / 13
        // to 1-12 with month type
        var adjustedMonth = mmonth % 13 + mmt

        let b = yo["myt"]! / 2

        // if big watat and common year
        let c = 1 - Int(floor(Double(yo["myt"]! + 1) / 2.0))
        // adjust month
        adjustedMonth += 4 - Int(floor(Double(adjustedMonth + 15) / 16.0)) * 4 + Int(floor(Double(adjustedMonth + 12) / 16.0))

        let dd = mmday + Int(floor(29.544 * Double(adjustedMonth) - 29.26)) - c * Int(floor(Double(adjustedMonth + 11) / 16.0)) * 30
            + b * Int(floor(Double(adjustedMonth + 12) / 16.0))

        let myl = 354 + (1 - c) * 30 + b

        // adjust day count with year length
        let adjustedDD = dd + mmt * myl

        return adjustedDD + yo["tg1"]! - 1
    }

    /// Calculate Julian day from Myanmar Year, Myanmar Month name and day of month
    /// - Parameters:
    ///   - myear: Myanmar Year (2 to 1500)
    ///   - myanmarMonthName: Myanmar month name
    ///   - mmday: day of month [from 1 to 29 or 30]
    /// - Returns: Julian Day Number
    /// - Throws: MyanmarDateError if month name is invalid
    static func getJulianDayNumber(_ myear: Int, _ myanmarMonthName: String, _ mmday: Int) throws -> Double {
        let mmonth = searchMyanmarMonthNumber(myanmarMonthName)
        if mmonth < 0 {
            throw MyanmarDateError.invalidMonthName("Invalid value for myanmarMonthName: \(myanmarMonthName)")
        }
        return Double(myanmarDateToJulian(myear, mmonth, mmday))
    }

    /// Myanmar Month name to Myanmar month number
    /// - Parameter myanmarMonthName: Myanmar month name
    /// - Returns: myanmar month number or -1 if invalid
    static func searchMyanmarMonthNumber(_ myanmarMonthName: String) -> Int {
        switch myanmarMonthName.lowercased() {
        case "first waso":
            return 0
        case "tagu":
            return 1
        case "kason":
            return 2
        case "nayon":
            return 3
        case "waso":
            return 4
        case "wagaung":
            return 5
        case "tawthalin":
            return 6
        case "thadingyut":
            return 7
        case "tazaungmon":
            return 8
        case "nadaw":
            return 9
        case "pyatho":
            return 10
        case "tabodwe":
            return 11
        case "tabaung":
            return 12
        case "late tagu":
            return 13
        case "late kason":
            return 14
        default:
            return -1
        }
    }

    /// Search moon phase by name
    /// - Parameter moonPhase: moon phase name
    /// - Returns: moon phase number or -1 if invalid
    static func searchMoonPhase(_ moonPhase: String) -> Int {
        switch moonPhase.lowercased() {
        case "waxing":
            return 0
        case "full moon":
            return 1
        case "waning":
            return 2
        case "new moon":
            return 3
        default:
            return -1
        }
    }
}
