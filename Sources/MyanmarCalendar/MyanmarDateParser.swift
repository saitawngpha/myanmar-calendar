import Foundation
import os

/// Parser for converting formatted Myanmar date strings back to `MyanmarDate` values.
///
/// Port of the Java `mmcalendar.MyanmarDateParser`. It leverages `LanguageTranslator`
/// and the `MyanmarDate.create` factories so it stays consistent with the rest of the library.
///
/// Supported pattern characters (same as `MyanmarDateFormat`):
/// - `S` — Sasana Year literal
/// - `s` — Buddhist Era year (number)
/// - `B` — Myanmar Year literal
/// - `y` — Myanmar year (number)
/// - `k` — Ku literal
/// - `M` — Month name
/// - `p` — Moon phase
/// - `f` — Fortnight day (number)
/// - `r` — Yat literal
/// - `E` — Weekday name (optional, for validation)
/// - `n` — Nay literal
///
/// Example:
/// ```swift
/// // English
/// let date = try MyanmarDateParser.parse(
///     "Myanmar Year 1385 Ku, Nadaw Waning 5 Yat",
///     "B y k, M p f r",
///     .english)
///
/// // Myanmar Unicode
/// let date = try MyanmarDateParser.parse(
///     "မြန်မာနှစ် ၁၃၈၅ ခု၊ နတ်တော် လဆုတ် ၅ ရက်",
///     "B y k, M p f r",
///     .myanmar)
/// ```
public struct MyanmarDateParser {

    private init() {}

    /// Errors thrown while parsing.
    public enum ParseError: Error, CustomStringConvertible {
        case emptyText
        case emptyPattern
        case noMatch(text: String, language: Language)
        case missingRequiredFields(String)
        case invalidFortnightDay(Int)
        case creationFailed(String)

        public var description: String {
            switch self {
            case .emptyText:
                return "Input text cannot be null or empty"
            case .emptyPattern:
                return "Pattern cannot be null or empty"
            case .noMatch(let text, let language):
                return "Text does not match pattern. Text: '\(text)', Language: \(language)"
            case .missingRequiredFields(let details):
                return "Failed to parse required fields from text. \(details)"
            case .invalidFortnightDay(let value):
                return "Fortnight day must be between 1 and 15, got: \(value)"
            case .creationFailed(let details):
                return details
            }
        }
    }

    /// Logged when the weekday in the input disagrees with the calculated weekday.
    /// Non-fatal, matching the Java implementation's `logger.warning`.
    private static let logger = Logger(subsystem: "MyanmarCalendar", category: "MyanmarDateParser")

    // MARK: - Parsed components

    private struct ParsedComponents: CustomStringConvertible {
        var myanmarYear: Int?
        var buddhistEra: Int?
        var monthName: String?      // In source language
        var moonPhaseName: String?  // In source language
        var fortnightDay: Int?
        var weekDayName: String?    // In source language (optional, for validation)

        /// Need: year + month + moon phase + fortnight day
        var hasRequiredFields: Bool {
            return myanmarYear != nil && monthName != nil
                && moonPhaseName != nil && fortnightDay != nil
        }

        var description: String {
            return "ParsedComponents{year=\(myanmarYear.map(String.init) ?? "null"), "
                + "month='\(monthName ?? "null")', phase='\(moonPhaseName ?? "null")', "
                + "fortnight=\(fortnightDay.map(String.init) ?? "null"), "
                + "weekday='\(weekDayName ?? "null")'}"
        }
    }

    // MARK: - Pattern cache

    private struct CacheKey: Hashable {
        let pattern: String
        let language: Language
    }

    private struct CompiledPattern {
        let regex: NSRegularExpression
        /// Which pattern chars have capture groups, in order
        let captureGroups: [Character]
    }

    private static let cacheLock = NSLock()
    private static var patternCache: [CacheKey: CompiledPattern] = [:]

    // MARK: - Public API

    /// Parses a Myanmar date string using the default pattern and configured language.
    public static func parse(_ text: String) throws -> MyanmarDate {
        return try parse(
            text,
            MyanmarDateFormat.simpleMyanmarDateFormatPattern,
            Config.getInstance().language
        )
    }

    /// Parses a Myanmar date string using the specified pattern and configured language.
    public static func parse(_ text: String, _ pattern: String) throws -> MyanmarDate {
        return try parse(text, pattern, Config.getInstance().language)
    }

    /// Parses a Myanmar date string using the specified pattern and language.
    /// - Parameters:
    ///   - text: the formatted Myanmar date string
    ///   - pattern: the pattern describing the date format
    ///   - language: the language of the input text
    /// - Returns: the parsed `MyanmarDate`
    /// - Throws: `ParseError` if parsing fails
    public static func parse(_ text: String, _ pattern: String, _ language: Language) throws -> MyanmarDate {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ParseError.emptyText
        }
        guard !pattern.isEmpty else {
            throw ParseError.emptyPattern
        }

        let compiled = try getOrCompilePattern(pattern, language)
        let components = try extractComponents(text, compiled, language)

        guard components.hasRequiredFields else {
            throw ParseError.missingRequiredFields(components.description)
        }

        return try buildMyanmarDate(components, language)
    }

    // MARK: - Compilation

    private static func getOrCompilePattern(_ pattern: String, _ language: Language) throws -> CompiledPattern {
        let key = CacheKey(pattern: pattern, language: language)

        cacheLock.lock()
        let cached = patternCache[key]
        cacheLock.unlock()

        if let cached = cached { return cached }

        let compiled = try compilePattern(pattern, language)

        cacheLock.lock()
        patternCache[key] = compiled
        cacheLock.unlock()

        return compiled
    }

    private static func compilePattern(_ pattern: String, _ language: Language) throws -> CompiledPattern {
        var regex = ""
        var captureGroups: [Character] = []

        for c in pattern {
            switch c {
            case MyanmarDateFormat.sasanaYear:
                regex += quote(LanguageTranslator.translate("Sasana Year", language))

            case MyanmarDateFormat.buddhistEra:
                regex += "(" + numberRegex(language) + ")"
                captureGroups.append(c)

            case MyanmarDateFormat.burmeseYear:
                regex += quote(LanguageTranslator.translate("Myanmar Year", language))

            case MyanmarDateFormat.myanmarYear:
                regex += "(" + numberRegex(language) + ")"
                captureGroups.append(c)

            case MyanmarDateFormat.ku:
                let ku = LanguageTranslator.translate("Ku", language)
                if !ku.isEmpty { regex += quote(ku) }

            case MyanmarDateFormat.monthInYear:
                regex += "(" + buildMonthRegex(language) + ")"
                captureGroups.append(c)

            case MyanmarDateFormat.moonPhase:
                regex += "(" + buildMoonPhaseRegex(language) + ")"
                captureGroups.append(c)

            case MyanmarDateFormat.fortnightDay:
                // Fortnight day is optional (empty for full moon / new moon), so `*` not `+`.
                if language == .english || language == .tai {
                    regex += "(\\d*)"
                } else {
                    regex += "([\\d၀-၉]*)"
                }
                captureGroups.append(c)

            case MyanmarDateFormat.dayNameInWeek:
                regex += "(" + buildWeekDayRegex(language) + ")"
                captureGroups.append(c)

            case MyanmarDateFormat.nay:
                let nay = LanguageTranslator.translate("Nay", language)
                if !nay.isEmpty { regex += quote(nay) }

            case MyanmarDateFormat.yat:
                let yat = LanguageTranslator.translate("Yat", language)
                if !yat.isEmpty { regex += quote(yat) }

            default:
                if c == " " {
                    // Flexible whitespace — zero or more
                    regex += "\\s*"
                } else if "[](){}.*+?^$|\\".contains(c) {
                    regex += "\\" + String(c)
                } else {
                    regex.append(c)
                }
            }
        }

        do {
            return CompiledPattern(
                regex: try NSRegularExpression(pattern: regex),
                captureGroups: captureGroups
            )
        } catch {
            throw ParseError.creationFailed("Failed to compile pattern '\(pattern)': \(error)")
        }
    }

    // MARK: - Extraction

    private static func extractComponents(
        _ text: String,
        _ compiled: CompiledPattern,
        _ language: Language
    ) throws -> ParsedComponents {

        let ns = text as NSString
        guard let match = compiled.regex.firstMatch(
            in: text,
            range: NSRange(location: 0, length: ns.length)
        ) else {
            throw ParseError.noMatch(text: text, language: language)
        }

        var components = ParsedComponents()
        var groupIndex = 1

        for patternChar in compiled.captureGroups {
            defer { groupIndex += 1 }

            let range = match.range(at: groupIndex)
            let captured: String? = range.location == NSNotFound ? nil : ns.substring(with: range)
            let trimmed = captured?.trimmingCharacters(in: .whitespacesAndNewlines)

            switch patternChar {
            case MyanmarDateFormat.buddhistEra:
                components.buddhistEra = parseNumber(captured, language)

            case MyanmarDateFormat.myanmarYear:
                components.myanmarYear = parseNumber(captured, language)

            case MyanmarDateFormat.monthInYear:
                if let trimmed = trimmed, !trimmed.isEmpty { components.monthName = trimmed }

            case MyanmarDateFormat.moonPhase:
                if let trimmed = trimmed, !trimmed.isEmpty { components.moonPhaseName = trimmed }

            case MyanmarDateFormat.fortnightDay:
                if let trimmed = trimmed, !trimmed.isEmpty {
                    components.fortnightDay = parseNumber(captured, language)
                } else {
                    // Default to 15 for full/new moon when the fortnight day is empty
                    components.fortnightDay = 15
                }

            case MyanmarDateFormat.dayNameInWeek:
                if let trimmed = trimmed, !trimmed.isEmpty { components.weekDayName = trimmed }

            default:
                break
            }
        }

        return components
    }

    // MARK: - Building

    private static func buildMyanmarDate(
        _ components: ParsedComponents,
        _ language: Language
    ) throws -> MyanmarDate {

        let myear = components.myanmarYear!

        // Translate month name to English with sentence translation, so multi-word
        // phrases such as "Second Waso" and "Late Tagu" resolve correctly.
        var monthNameEn = LanguageTranslator.translateSentence(components.monthName!, language, .english)
        let moonPhaseEn = LanguageTranslator.translateSentence(components.moonPhaseName!, language, .english)

        let fortnightDay = components.fortnightDay!

        guard (1...15).contains(fortnightDay) else {
            throw ParseError.invalidFortnightDay(fortnightDay)
        }

        // "Second Waso" is just Waso (month 4); "First Waso" is already month 0.
        if monthNameEn.lowercased() == "second waso" {
            monthNameEn = "Waso"
        }

        let mmonth = MyanmarDateKernel.searchMyanmarMonthNumber(monthNameEn)
        let moonPhase = MyanmarDateKernel.searchMoonPhase(moonPhaseEn)
        let monthDay = MyanmarCalendarKernel.calculateDayOfMonth(myear, mmonth, moonPhase, fortnightDay)

        do {
            // Create from year, month and day of month so the moon phase comes out right.
            let result = try MyanmarDate.create(myear: myear, mmonth: mmonth, monthDay: monthDay)

            // Optional: validate the weekday if one was provided
            if let parsedWeekday = components.weekDayName {
                let actualWeekday = result.getWeekDay(language)
                if parsedWeekday != actualWeekday {
                    logger.warning(
                        "Parsed weekday '\(parsedWeekday, privacy: .public)' doesn't match calculated weekday '\(actualWeekday, privacy: .public)'"
                    )
                }
            }

            return result
        } catch {
            throw ParseError.creationFailed(
                "Failed to create MyanmarDate with year=\(myear), month='\(monthNameEn)', "
                + "moonPhase='\(moonPhaseEn)', fortnightDay=\(fortnightDay): \(error)"
            )
        }
    }

    // MARK: - Helpers

    /// Equivalent of Java's `Pattern.quote` — treats the whole string as a literal.
    private static func quote(_ s: String) -> String {
        return "\\Q" + s + "\\E"
    }

    private static func numberRegex(_ language: Language) -> String {
        if language == .english || language == .tai {
            return "\\d+"
        }
        // Myanmar, Zawgyi, Mon and Karen use Myanmar digits
        return "[\\d၀-၉]+"
    }

    private static func parseNumber(_ numberStr: String?, _ language: Language) -> Int? {
        guard let raw = numberStr?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else {
            return nil
        }

        if language == .english || language == .tai {
            return Int(raw)
        }

        // Convert Myanmar digits to ASCII
        var arabic = ""
        for c in raw.unicodeScalars {
            if c >= "၀" && c <= "၉" {
                arabic.append(Character(UnicodeScalar(c.value - UnicodeScalar("၀").value + 48)!))
            } else if c >= "0" && c <= "9" {
                arabic.unicodeScalars.append(c)
            }
        }

        return Int(arabic)
    }

    /// Builds the month-name alternation, handling the First / Second / Late prefixes.
    private static func buildMonthRegex(_ language: Language) -> String {
        var monthPatterns: [String] = []

        func add(_ p: String) {
            if !monthPatterns.contains(p) { monthPatterns.append(p) }
        }

        let first = LanguageTranslator.translate("First", language)
        let second = LanguageTranslator.translate("Second", language)
        let late = LanguageTranslator.translate("Late", language)

        let monthKeys = ["Tagu", "Kason", "Nayon", "Waso", "Wagaung", "Tawthalin",
                         "Thadingyut", "Tazaungmon", "Nadaw", "Pyatho", "Tabodwe", "Tabaung"]

        for key in monthKeys {
            let month = LanguageTranslator.translate(key, language)

            add(quote(month))

            if key == "Waso" {
                add(quote(first) + "\\s*" + quote(month))
                add(quote(second) + "\\s*" + quote(month))
            }
            if key == "Tagu" || key == "Kason" {
                add(quote(late) + "\\s*" + quote(month))
            }
        }

        add(quote(LanguageTranslator.translate("Late Tagu", language)))
        add(quote(LanguageTranslator.translate("Late Kason", language)))

        // Longest first, so the alternation matches greedily. Stable, like Java's List.sort.
        return stableSortedByLengthDescending(monthPatterns).joined(separator: "|")
    }

    private static func buildMoonPhaseRegex(_ language: Language) -> String {
        let phaseKeys = ["Waxing", "Full Moon", "Waning", "New Moon"]
        let phases = phaseKeys.map { quote(LanguageTranslator.translate($0, language)) }
        return stableSortedByLengthDescending(phases).joined(separator: "|")
    }

    private static func buildWeekDayRegex(_ language: Language) -> String {
        let weekdayKeys = ["Saturday", "Sunday", "Monday", "Tuesday",
                           "Wednesday", "Thursday", "Friday"]
        return weekdayKeys
            .map { quote(LanguageTranslator.translate($0, language)) }
            .joined(separator: "|")
    }

    /// Swift's `sort` is not guaranteed stable; Java's `List.sort` is. Decorate with the
    /// original index so equal-length entries keep their insertion order.
    private static func stableSortedByLengthDescending(_ values: [String]) -> [String] {
        return values.enumerated()
            .sorted { lhs, rhs in
                // Java compares String.length(), i.e. UTF-16 code units, not grapheme clusters.
                if lhs.element.utf16.count != rhs.element.utf16.count {
                    return lhs.element.utf16.count > rhs.element.utf16.count
                }
                return lhs.offset < rhs.offset
            }
            .map { $0.element }
    }
}
