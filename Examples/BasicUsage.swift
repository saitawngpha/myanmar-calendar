import Foundation
import MyanmarCalendar

/// Basic usage examples for Myanmar Calendar Swift package

func basicExamples() {
    print("=== Myanmar Calendar Swift - Basic Examples ===\n")

    // Example 1: Convert Western date to Myanmar date
    do {
        print("Example 1: Convert 2024-01-01 to Myanmar date")
        let myanmarDate = try MyanmarDate.of(year: 2024, month: 1, day: 1)
        print("Myanmar Year: \(myanmarDate.getYear(.english))")
        print("Month: \(myanmarDate.getMonthName(.english))")
        print("Moon Phase: \(myanmarDate.getMoonPhase(.english))")
        print("Weekday: \(myanmarDate.getWeekDay(.english))")
        print("Buddhist Era: \(myanmarDate.getBuddhistEraValue())")
        print()
    } catch {
        print("Error: \(error)")
    }

    // Example 2: Get current Myanmar date
    do {
        print("Example 2: Current Myanmar date")
        let now = try MyanmarDate.now()
        print("Description: \(now.description)")
        print()
    } catch {
        print("Error: \(error)")
    }

    // Example 3: Create Myanmar date directly
    do {
        print("Example 3: Create Myanmar date directly")
        let myanmarDate = try MyanmarDate.create(myear: 1385, mmonth: 9, monthDay: 5)
        let westernDate = myanmarDate.toWesternDate()
        print("Myanmar: Year \(myanmarDate.getYearValue()), Month \(myanmarDate.getMonthName(.english)), Day \(myanmarDate.monthDay)")
        print("Western: \(westernDate.year)-\(westernDate.month)-\(westernDate.day)")
        print()
    } catch {
        print("Error: \(error)")
    }

    // Example 4: Multi-language support
    do {
        print("Example 4: Multi-language support")
        let myanmarDate = try MyanmarDate.of(year: 2024, month: 4, day: 15)

        print("English: \(myanmarDate.getMonthName(.english)) - \(myanmarDate.getWeekDay(.english))")
        print("Myanmar: \(myanmarDate.getMonthName(.myanmar)) - \(myanmarDate.getWeekDay(.myanmar))")
        print()
    } catch {
        print("Error: \(error)")
    }

    // Example 5: Date formatting
    do {
        print("Example 5: Date formatting")
        let myanmarDate = try MyanmarDate.of(year: 2024, month: 1, day: 1)

        let englishFormat = myanmarDate.format("S s k, B y k, M p f r E n", .english)
        print("English: \(englishFormat)")

        let myanmarFormat = myanmarDate.format("S s k, B y k, M p f r E n", .myanmar)
        print("Myanmar: \(myanmarFormat)")
        print()
    } catch {
        print("Error: \(error)")
    }

    // Example 6: Configuration
    print("Example 6: Configure default language and calendar")
    let config = Config.Builder()
        .setCalendarType(.gregorian)
        .setLanguage(.english)
        .build()
    Config.initDefault(config)
    print("Config set to: Gregorian calendar, English language")
    print()
}

// Run examples if this file is executed as a script
#if swift(>=5.9)
if CommandLine.arguments.contains("--run-examples") {
    basicExamples()
}
#endif
