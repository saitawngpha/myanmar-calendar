import XCTest
@testable import MyanmarCalendar

/// Covers the API ported from the Java reference (chanmratekoko/mmcalendar):
/// the public kernels, the extra `MyanmarDate` accessors, `Astro`'s localized
/// getters, and `MyanmarDateParser`.
final class MyanmarCalendarAPITests: XCTestCase {

    // MARK: - Kernels are reachable from outside the module

    func testKernelsArePublic() throws {
        let jdn = MyanmarDateKernel.myanmarDateToJulian(1385, 9, 5)
        let date = try MyanmarDateKernel.julianToMyanmarDate(Double(jdn))
        XCTAssertEqual(date.getYearValue(), 1385)
        XCTAssertEqual(date.getMonth(), 9)
        XCTAssertEqual(date.getDayOfMonth(), 5)

        let yearInfo = MyanmarDateKernel.checkMyanmarYear(1385)
        XCTAssertNotNil(yearInfo["myt"])
        XCTAssertNotNil(yearInfo["tg1"])
        XCTAssertEqual(MyanmarDateKernel.checkWatat(1385)["watat"], 1)

        XCTAssertEqual(MyanmarDateKernel.searchMyanmarMonthNumber("Nadaw"), 9)
        XCTAssertEqual(MyanmarDateKernel.searchMoonPhase("Full Moon"), 1)

        XCTAssertEqual(WesternDateKernel.getLengthOfMonth(2024, 2, 0), 29)
        XCTAssertEqual(WesternDateKernel.getLengthOfMonth(1752, 9, 0), 19)

        XCTAssertEqual(AstroKernel.calculateNakhat(1385), 1385 % 3)
        XCTAssertEqual(BinarySearchUtil.search(3, [1, 2, 3, 4]), 2)
        XCTAssertEqual(BinarySearchUtil.search(99, [1, 2, 3, 4]), -1)
    }

    func testEraConstantsAreTyped() {
        let third = MyanmarYearConstants.getMyConst(1385)
        XCTAssertEqual(third.eraId, 3)
        XCTAssertEqual(third.numberOfMonths, 8)

        let second = MyanmarYearConstants.getMyConst(1250)
        XCTAssertEqual(second.eraId, 2)
        XCTAssertEqual(second.watatOffset, -1)

        // 1344 is a watat exception year in the third era
        XCTAssertEqual(MyanmarYearConstants.getMyConst(1344).exceptionInWatatYear, 1)
    }

    func testHolidayPredicatesArePublic() {
        XCTAssertEqual(HolidayCalculator.englishHoliday(2019, 1, 4), ["Independence Day"])
        XCTAssertEqual(HolidayCalculator.myanmarHoliday(1385, 2, 15, 1), ["Buddha Day"])
        XCTAssertEqual(HolidayCalculator.continuousHoliday(2024, 12, 31), ["Holiday"])
    }

    // MARK: - The 2018-2021 precedence regression

    func testHolidaysAreNotSwallowedByNewYearsDay() {
        // A single misplaced parenthesis used to make every day of 2018-2021
        // report "New Year's Day" and mask everything after it in the chain.
        for year in 2018...2021 {
            XCTAssertEqual(HolidayCalculator.englishHoliday(year, 1, 1), ["New Year's Day"])
            XCTAssertEqual(HolidayCalculator.englishHoliday(year, 1, 4), ["Independence Day"])
            XCTAssertEqual(HolidayCalculator.englishHoliday(year, 2, 12), ["Union Day"])
            XCTAssertEqual(HolidayCalculator.englishHoliday(year, 7, 19), ["Martyrs' Day"])
            XCTAssertEqual(HolidayCalculator.englishHoliday(year, 12, 25), ["Christmas Day"])
            XCTAssertTrue(HolidayCalculator.englishHoliday(year, 6, 6).isEmpty)
        }
    }

    func testSubstituteBusinessDay() {
        XCTAssertEqual(BusinessDayCalculator.substituteBusinessDay(2026, 1, 10), ["Business Day"])
        XCTAssertTrue(BusinessDayCalculator.substituteBusinessDay(2026, 1, 3).isEmpty)
    }

    // MARK: - MyanmarDate additions

    func testMyanmarDateAccessors() throws {
        let date = try MyanmarDate.of(year: 2024, month: 1, day: 1)

        XCTAssertEqual(date.getYearType(), date.yearType)
        XCTAssertEqual(date.getMonthType(), date.monthType)
        XCTAssertEqual(date.getFortnightDayValue(), date.fortnightDay)
        XCTAssertEqual(date.lengthOfYear(), date.yearLength)
        XCTAssertEqual(date.lengthOfMonth(), date.monthLength)

        // 2024-01-01 was a Monday
        XCTAssertEqual(date.getWeekDay(.english), "Monday")
        XCTAssertFalse(date.isWeekend())

        let saturday = try MyanmarDate.of(year: 2024, month: 1, day: 6)
        XCTAssertTrue(saturday.isWeekend())
        let sunday = try MyanmarDate.of(year: 2024, month: 1, day: 7)
        XCTAssertTrue(sunday.isWeekend())
    }

    func testMntQualifier() throws {
        // Second Waso of a watat year
        let secondWaso = try MyanmarDate.create(myear: 1385, mmonth: 4, monthDay: 1)
        XCTAssertEqual(secondWaso.getMnt(.english), "Second")

        // An ordinary early month has no qualifier
        let nadaw = try MyanmarDate.create(myear: 1385, mmonth: 9, monthDay: 1)
        XCTAssertEqual(nadaw.getMonthType(), 0)
        XCTAssertEqual(nadaw.getMnt(.english), "")

        // A late (hnaung) month. Note ME 1385 is a watat year, so Tagu 1 itself
        // resolves to Late Tagu - matching the Java reference.
        let lateTagu = try MyanmarDate.create(myear: 1385, mmonth: 13, monthDay: 1)
        XCTAssertEqual(lateTagu.getMonth(), 13)
        XCTAssertEqual(lateTagu.getMnt(.english), "Late")
        XCTAssertEqual(try MyanmarDate.create(myear: 1385, mmonth: 1, monthDay: 1).getMonth(), 13)
    }

    func testDayArithmeticAndComparison() throws {
        let date = try MyanmarDate.of(year: 2024, month: 1, day: 1)
        let later = try date.plusDays(10)
        let earlier = try date.minusDays(10)

        XCTAssertEqual(later.jd, date.jd + 10)
        XCTAssertEqual(earlier.jd, date.jd - 10)
        XCTAssertTrue(date.isBefore(later))
        XCTAssertTrue(date.isAfter(earlier))
        XCTAssertFalse(date.isBefore(earlier))

        XCTAssertTrue(date.hasSameDay(date))
        XCTAssertFalse(date.hasSameDay(later))

        // plusDays(-n) == minusDays(n)
        XCTAssertEqual(try date.plusDays(-10).jd, earlier.jd)
    }

    func testWesternDateValidation() {
        XCTAssertThrowsError(try MyanmarDate.of(year: 2024, month: 13, day: 1))
        XCTAssertThrowsError(try MyanmarDate.of(year: 2024, month: 0, day: 1))
        XCTAssertThrowsError(try MyanmarDate.of(year: 2024, month: 1, day: 0))
        XCTAssertThrowsError(try MyanmarDate.of(year: 2024, month: 1, day: 32))
        XCTAssertNoThrow(try MyanmarDate.of(year: 2024, month: 12, day: 31))
    }

    func testCreateFromMoonPhaseAndFortnightDay() throws {
        let fromParts = try MyanmarDate.create(myear: 1385, mmonth: 9, moonPhase: 2, fortnightDay: 5)
        XCTAssertEqual(fromParts.getMoonPhaseValue(), 2)
        XCTAssertEqual(fromParts.getFortnightDayValue(), 5)
        XCTAssertEqual(fromParts.getMonth(), 9)

        let fromNames = try MyanmarDate.create(
            myear: 1385, myanmarMonthName: "Nadaw", moonPhase: "Waning", fortnightDay: 5)
        XCTAssertEqual(fromNames.jd, fromParts.jd)
    }

    func testFortnightDayIsBlankOnFullAndNewMoon() throws {
        let fullMoon = try MyanmarDate.create(myear: 1385, mmonth: 9, moonPhase: 1, fortnightDay: 15)
        XCTAssertEqual(fullMoon.getMoonPhaseValue(), 1)
        XCTAssertEqual(fullMoon.getFortnightDay(.english), "")
        XCTAssertEqual(fullMoon.getFortnightDayValue(), 15)

        let newMoon = try MyanmarDate.create(myear: 1385, mmonth: 9, moonPhase: 3, fortnightDay: 15)
        XCTAssertEqual(newMoon.getFortnightDay(.english), "")

        let waxing = try MyanmarDate.create(myear: 1385, mmonth: 9, moonPhase: 0, fortnightDay: 5)
        XCTAssertEqual(waxing.getFortnightDay(.english), "5")
    }

    func testToStringUsesSimplePattern() throws {
        let date = try MyanmarDate.of(year: 2024, month: 1, day: 1)
        XCTAssertEqual(
            date.toString(.english),
            date.format(MyanmarDateFormat.simpleMyanmarDateFormatPattern, .english))
        XCTAssertTrue(date.toString(.english).contains("Sasana Year"))
    }

    // MARK: - Astro

    func testAstroLocalizedGetters() throws {
        let date = try MyanmarDate.of(year: 2024, month: 1, day: 1)
        let astro = Astro.of(date)

        XCTAssertEqual(astro.getNagahleValue(), astro.nagahle)
        XCTAssertEqual(astro.getMahaboteValue(), astro.mahabote)
        XCTAssertEqual(astro.getNakhatValue(), astro.nakhat)
        XCTAssertEqual(astro.getSabbathValue(), astro.sabbath)
        XCTAssertEqual(astro.getPyathadaValue(), astro.pyathada)

        XCTAssertTrue(["West", "North", "East", "South"].contains(astro.getNagahle(.english)))
        XCTAssertTrue(["Binga", "Atun", "Yaza", "Adipati", "Marana", "Thike", "Puti"]
            .contains(astro.getMahabote(.english)))
        XCTAssertTrue(["Ogre", "Elf", "Human"].contains(astro.getNakhat(.english)))
        XCTAssertFalse(astro.getYearName(.english).isEmpty)
        XCTAssertFalse(astro.toString(.english).isEmpty)

        // Flag getters return the name only when the flag is set
        XCTAssertEqual(astro.getYatyaza(.english), astro.isYatyaza ? "Yatyaza" : "")
        XCTAssertEqual(astro.getThamanyo(.english), astro.isThamanyo ? "Thamanyo" : "")
    }

    func testAstroPyathadaVariants() throws {
        // Afternoon Pyathada renders both words
        var found = false
        for offset in 0..<120 {
            let date = try MyanmarDate.of(year: 2024, month: 1, day: 1).plusDays(offset)
            let astro = Astro.of(date)
            if astro.getPyathadaValue() == 2 {
                XCTAssertEqual(astro.getPyathada(.english), "Afternoon Pyathada")
                found = true
                break
            }
        }
        XCTAssertTrue(found, "expected an afternoon pyathada within 120 days")
    }

    func testAstroSabbathHelpers() throws {
        var sawSabbath = false
        var sawEve = false
        for offset in 0..<40 {
            let date = try MyanmarDate.of(year: 2024, month: 1, day: 1).plusDays(offset)
            let astro = Astro.of(date)
            if astro.isSabbath {
                XCTAssertEqual(astro.getSabbath(.english), "Sabbath")
                XCTAssertEqual(astro.getSabbathOrEve(.english), "Sabbath")
                XCTAssertEqual(astro.getSabbathEve(.english), "")
                sawSabbath = true
            }
            if astro.isSabbathEve {
                XCTAssertEqual(astro.getSabbathEve(.english), "Sabbath Eve")
                XCTAssertEqual(astro.getSabbathOrEve(.english), "Sabbath Eve")
                sawEve = true
            }
        }
        XCTAssertTrue(sawSabbath && sawEve)
    }

    // MARK: - Parser

    func testParserEnglishExample() throws {
        let parsed = try MyanmarDateParser.parse(
            "Myanmar Year 1385 Ku, Nadaw Waning 5 Yat", "B y k, M p f r", .english)

        XCTAssertEqual(parsed.getYearValue(), 1385)
        XCTAssertEqual(parsed.getMonth(), 9)
        XCTAssertEqual(parsed.getMoonPhaseValue(), 2)
        XCTAssertEqual(parsed.getFortnightDayValue(), 5)
    }

    func testParserMyanmarExample() throws {
        let parsed = try MyanmarDateParser.parse(
            "မြန်မာနှစ် ၁၃၈၅ ခု, နတ်တော် လဆုတ် ၅ ရက်", "B y k, M p f r", .myanmar)

        XCTAssertEqual(parsed.getYearValue(), 1385)
        XCTAssertEqual(parsed.getMonth(), 9)
        XCTAssertEqual(parsed.getMoonPhaseValue(), 2)
        XCTAssertEqual(parsed.getFortnightDayValue(), 5)
    }

    /// The upstream javadoc example writes the separator as the Myanmar comma "၊"
    /// while the pattern spells an ASCII ",", so it does not match. The Java
    /// reference rejects it too; this pins that behaviour rather than diverging.
    func testParserRejectsUpstreamJavadocExampleSeparator() {
        XCTAssertThrowsError(try MyanmarDateParser.parse(
            "မြန်မာနှစ် ၁၃၈၅ ခု၊ နတ်တော် လဆုတ် ၅ ရက်", "B y k, M p f r", .myanmar))
    }

    func testParserRoundTripsEveryLanguage() throws {
        let pattern = "B y k, M p f r"

        for language in Language.allCases {
            // Sweep a full lunar cycle plus a watat month boundary
            for offset in stride(from: 0, through: 400, by: 7) {
                let original = try MyanmarDate.of(year: 2024, month: 1, day: 1).plusDays(offset)
                let text = original.format(pattern, language)
                let parsed = try MyanmarDateParser.parse(text, pattern, language)

                XCTAssertEqual(
                    parsed.jd, original.jd,
                    "round trip failed for \(language) offset \(offset): '\(text)'")
            }
        }
    }

    func testParserRoundTripsDefaultPattern() throws {
        let pattern = MyanmarDateFormat.simpleMyanmarDateFormatPattern

        for language in Language.allCases {
            for offset in stride(from: 0, through: 200, by: 11) {
                let original = try MyanmarDate.of(year: 2024, month: 1, day: 1).plusDays(offset)
                let text = original.format(pattern, language)
                let parsed = try MyanmarDateParser.parse(text, pattern, language)
                XCTAssertEqual(parsed.jd, original.jd, "'\(text)' (\(language))")
            }
        }
    }

    func testParserHandlesFullMoonWithNoFortnightDay() throws {
        let fullMoon = try MyanmarDate.create(myear: 1385, mmonth: 9, moonPhase: 1, fortnightDay: 15)
        let pattern = "B y k, M p f r"
        let text = fullMoon.format(pattern, .english)

        // The fortnight day is blank on a full moon; the parser defaults it to 15.
        XCTAssertFalse(text.contains("15"))
        let parsed = try MyanmarDateParser.parse(text, pattern, .english)
        XCTAssertEqual(parsed.jd, fullMoon.jd)
        XCTAssertEqual(parsed.getMoonPhaseValue(), 1)
    }

    func testParserHandlesSecondAndLateMonths() throws {
        let pattern = "B y k, M p f r"

        // Second Waso of a watat year maps back to month 4
        let secondWaso = try MyanmarDate.create(myear: 1385, mmonth: 4, monthDay: 5)
        XCTAssertEqual(secondWaso.getMonthName(.english), "Second Waso")
        let parsedWaso = try MyanmarDateParser.parse(
            secondWaso.format(pattern, .english), pattern, .english)
        XCTAssertEqual(parsedWaso.jd, secondWaso.jd)

        // Late Tagu maps back to month 13
        let lateTagu = try MyanmarDate.create(myear: 1385, mmonth: 13, monthDay: 5)
        XCTAssertEqual(lateTagu.getMonthName(.english), "Late Tagu")
        let parsedLate = try MyanmarDateParser.parse(
            lateTagu.format(pattern, .english), pattern, .english)
        XCTAssertEqual(parsedLate.jd, lateTagu.jd)
    }

    func testParserRejectsBadInput() {
        XCTAssertThrowsError(try MyanmarDateParser.parse("", "B y k, M p f r", .english))
        XCTAssertThrowsError(try MyanmarDateParser.parse("   ", "B y k, M p f r", .english))
        XCTAssertThrowsError(try MyanmarDateParser.parse("anything", "", .english))
        XCTAssertThrowsError(try MyanmarDateParser.parse("not a date at all", "B y k, M p f r", .english))

        // A pattern with no year field cannot produce a date - matches the Java behaviour.
        XCTAssertThrowsError(try MyanmarDateParser.parse("Nadaw Waning 5 Yat", "M p f r", .english))
    }

    // MARK: - Translator

    func testTranslatorCoversEveryLanguage() {
        // Mon, Tai and Sgaw Karen used to fall through untranslated.
        XCTAssertEqual(LanguageTranslator.translate("Kason", .mon), "ဂိတုပသာ်")
        XCTAssertEqual(LanguageTranslator.translate("Kason", .tai), "ႁူၵ်း")
        XCTAssertEqual(LanguageTranslator.translate("Kason", .sgawKaren), "ဒ့ၣ်ညါ")

        // Tai uses ASCII digits, everyone else uses Myanmar digits.
        XCTAssertEqual(LanguageTranslator.translate(1385, .tai), "1385")
        XCTAssertEqual(LanguageTranslator.translate(1385, .myanmar), "၁၃၈၅")
        XCTAssertEqual(LanguageTranslator.translate(1385, .english), "1385")
        XCTAssertEqual(LanguageTranslator.translate(0, .myanmar), "၀")
        XCTAssertEqual(LanguageTranslator.translate(-5, .myanmar), "-၅")
    }

    func testTranslateSentenceUsesLongestPrefixMatch() {
        // "Independence Day" is not a catalog entry; "Independence" is, "Day" is.
        XCTAssertEqual(
            LanguageTranslator.translateSentence("Independence Day", .english, .myanmar),
            "လွတ်လပ်ရေး နေ့")

        // Round trip back to English. Myanmar "နေ့" is both "Nay" and "Day" in the
        // catalog; the later row wins, as in Java's map/trie population order.
        XCTAssertEqual(
            LanguageTranslator.translateSentence("လွတ်လပ်ရေး နေ့", .myanmar, .english),
            "Independence Day")
        XCTAssertEqual(LanguageTranslator.translate("နေ့", .myanmar, .english), "Day")

        // Unknown text passes through untouched
        XCTAssertEqual(LanguageTranslator.translateSentence("zzz", .english, .myanmar), "zzz")
    }

    /// Regression: the sentence trie must walk UTF-16 code units, not Swift
    /// `Character`s. In Zawgyi a space followed by U+1031 forms a single grapheme
    /// cluster, which used to hide the start of the next word from the matcher.
    func testTranslateSentenceHandlesZawgyiSpacingVowel() {
        let zawgyi = LanguageTranslator.translateSentence("Independence Day", .english, .zawgyi)
        XCTAssertEqual(zawgyi, "လြတ္လပ္ေရး ေန႔")
        XCTAssertEqual(LanguageTranslator.translateSentence(zawgyi, .zawgyi, .english), "Independence Day")
    }

    /// Every catalog word must translate correctly in all 36 language pairs.
    ///
    /// A handful of source words are ambiguous (Karen "မုၢ်ဖီဖး" is both "Good Friday"
    /// and "Friday"; "နေ့" is both "Nay" and "Day"). Those resolve to the *last*
    /// matching catalog row, so they are checked against that row rather than their own.
    func testTranslateSentenceIsCorrectAcrossAllLanguagePairs() {
        let catalog = LanguageTranslator.catalog

        for from in Language.allCases {
            // The last row that claims each source word wins
            var winner: [String: [String]] = [:]
            for row in catalog where !row[from.languageIndex].isEmpty {
                winner[row[from.languageIndex]] = row
            }

            for row in catalog {
                let source = row[from.languageIndex]
                guard !source.isEmpty, let expectedRow = winner[source] else { continue }

                for to in Language.allCases {
                    XCTAssertEqual(
                        LanguageTranslator.translateSentence(source, from, to),
                        expectedRow[to.languageIndex],
                        "\(from) -> \(to) for '\(source)'")
                    XCTAssertEqual(
                        LanguageTranslator.translate(source, from, to),
                        expectedRow[to.languageIndex],
                        "word lookup \(from) -> \(to) for '\(source)'")
                }
            }
        }
    }

    func testHolidayNamesAreTranslated() throws {
        let independence = try MyanmarDate.of(year: 2024, month: 1, day: 4)
        XCTAssertEqual(HolidayCalculator.getHoliday(independence, .english, .english), ["Independence Day"])
        XCTAssertEqual(HolidayCalculator.getHoliday(independence, .english, .myanmar), ["လွတ်လပ်ရေး နေ့"])
        XCTAssertEqual(HolidayCalculator.getHoliday(independence, .english, .mon), ["သၠးပွး တ္ၚဲ"])
    }
}
