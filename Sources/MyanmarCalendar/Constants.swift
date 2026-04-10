import Foundation

/// Constants Value for Algorithm Calculation
public struct Constants {

    /// Solar year (365.2587565) (1577917828 / 4320000.0)
    public static let SY: Double = 365.2587564814815

    /// Lunar month (29.53058795) (1577917828 / 53433336.0)
    public static let LM: Double = 29.53058794607172

    /// Beginning of 0 ME
    /// Starting year of Myanmar era (year 0)
    public static let MO: Double = 1954168.050623

    /// Beginning of 3rd Era
    public static let SE3: Int = 1312

    /// Beginning of English Calendar
    public static let BY: Int = 640

    /// End of English Calendar
    public static let EY: Int = 2140

    /// Beginning of Myanmar Calendar
    public static let MBY: Int = 2

    /// End of Myanmar Calendar
    public static let MEY: Int = 1500

    /// Minimum accurate English Year
    public static let LT: Int = 1700

    /// Maximum accurate English Year
    public static let UT: Int = 2018

    /// Minimum accurate Myanmar Year
    public static let MLT: Int = 1062

    /// Maximum accurate Myanmar Year
    public static let MUT: Int = 1379

    /// Gregorian start in English calendar (1752/Sep/14)
    public static let SG: Double = 2361222

    /// Myanmar Month Names
    static let EMA: [String] = [
        "First Waso",
        "Tagu",
        "Kason",
        "Nayon",
        "Waso",
        "Wagaung",
        "Tawthalin",
        "Thadingyut",
        "Tazaungmon",
        "Nadaw",
        "Pyatho",
        "Tabodwe",
        "Tabaung",
        "Late Tagu",
        "Late Kason"
    ]

    /// New Moon mean Dark moon
    static let MSA: [String] = [
        "Waxing",
        "Full Moon",
        "Waning",
        "New Moon"
    ]

    /// Week Days
    static let WDA: [String] = [
        "Saturday",
        "Sunday",
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday"
    ]

    /// Myanmar Time Zone Identifier
    public static let MYANMAR_ZONE_ID = "Asia/Rangoon"

    private init() {}
}
