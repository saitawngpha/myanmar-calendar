import XCTest
@testable import MyanmarCalendar

final class MyanmarCalendarTests: XCTestCase {

    func testBasicDateConversion() throws {
        // Test converting 2024-01-01 to Myanmar Date
        let myanmarDate = try MyanmarDate.of(year: 2024, month: 1, day: 1)

        // Verify the conversion
        XCTAssertEqual(myanmarDate.getYearValue(), 1385)
        XCTAssertEqual(myanmarDate.getMonthName(.english), "Nadaw")
        XCTAssertTrue(myanmarDate.getBuddhistEraValue() > 2000)
    }

    func testMyanmarDateCreation() throws {
        // Create a Myanmar date directly
        let myanmarDate = try MyanmarDate.create(myear: 1385, mmonth: 9, monthDay: 5)

        XCTAssertEqual(myanmarDate.getYearValue(), 1385)
        XCTAssertEqual(myanmarDate.getMonth(), 9)
    }

    func testWesternDateConversion() throws {
        // Create WesternDate and convert to Myanmar
        let westernDate = WesternDate(year: 2024, month: 4, day: 15)
        let myanmarDate = try westernDate.toMyanmarDate()

        XCTAssertEqual(myanmarDate.getYearValue(), 1385)
        XCTAssertNotNil(myanmarDate.toWesternDate())
    }

    func testMonthNames() throws {
        let myanmarDate = try MyanmarDate.of(year: 2024, month: 1, day: 1)

        // Test English month name
        let englishMonth = myanmarDate.getMonthName(.english)
        XCTAssertEqual(englishMonth, "Nadaw")

        // Test Myanmar month name
        let myanmarMonth = myanmarDate.getMonthName(.myanmar)
        XCTAssertTrue(myanmarMonth.contains("နတ်တော်"))
    }

    func testWeekDay() throws {
        // 2024-01-01 is a Monday
        let myanmarDate = try MyanmarDate.of(year: 2024, month: 1, day: 1)
        let weekDay = myanmarDate.getWeekDay(.english)
        XCTAssertEqual(weekDay, "Monday")
    }

    func testFormatting() throws {
        let myanmarDate = try MyanmarDate.of(year: 2024, month: 1, day: 1)

        // Test basic formatting
        let formatted = myanmarDate.format("y M", .english)
        XCTAssertTrue(formatted.contains("1385"))
        XCTAssertTrue(formatted.contains("Nadaw"))
    }

    func testLanguageTranslation() {
        // Test number translation
        let englishNumber = LanguageTranslator.translate(123, .english)
        XCTAssertEqual(englishNumber, "123")

        let myanmarNumber = LanguageTranslator.translate(123, .myanmar)
        XCTAssertTrue(myanmarNumber.contains("၁"))
    }

    func testBuddhistEra() throws {
        let myanmarDate = try MyanmarDate.of(year: 2024, month: 1, day: 1)
        let buddhistEra = myanmarDate.getBuddhistEraValue()
        XCTAssertEqual(buddhistEra, 2567)
    }

    func testDateRoundTrip() throws {
        // Test converting to WesternDate and back
        let originalDate = try MyanmarDate.of(year: 2024, month: 4, day: 15)
        let westernDate = originalDate.toWesternDate()
        let backToMyanmar = try westernDate.toMyanmarDate()

        XCTAssertEqual(originalDate.getYearValue(), backToMyanmar.getYearValue())
        XCTAssertEqual(originalDate.getMonth(), backToMyanmar.getMonth())
    }
}
