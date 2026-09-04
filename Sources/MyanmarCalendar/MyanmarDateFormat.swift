import Foundation

/// Pattern characters understood by `MyanmarDate.format(_:_:)` and `MyanmarDateParser`.
///
/// Port of the Java `mmcalendar.MyanmarDateFormat`.
public struct MyanmarDateFormat {

    /// `S` — Sasana Year literal
    public static let sasanaYear: Character = "S"

    /// `s` — Buddhist Era year (number)
    public static let buddhistEra: Character = "s"

    /// `B` — Myanmar Year literal
    public static let burmeseYear: Character = "B"

    /// `y` — Myanmar year (number)
    public static let myanmarYear: Character = "y"

    /// `k` — Ku literal
    public static let ku: Character = "k"

    /// `M` — Month name
    public static let monthInYear: Character = "M"

    /// `p` — Moon phase
    public static let moonPhase: Character = "p"

    /// `f` — Fortnight day (number)
    public static let fortnightDay: Character = "f"

    /// `E` — Weekday name
    public static let dayNameInWeek: Character = "E"

    /// `n` — Nay literal
    public static let nay: Character = "n"

    /// `r` — Yat literal
    public static let yat: Character = "r"

    /// The default pattern: `"S s k, B y k, M p f r E n"`
    public static let simpleMyanmarDateFormatPattern = "S s k, B y k, M p f r E n"

    private init() {}
}
