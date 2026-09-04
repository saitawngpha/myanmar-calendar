# Myanmar Calendar (Swift)

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%20|%20macOS%20|%20tvOS%20|%20watchOS-lightgrey.svg)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**Myanmar Calendar** library for Swift applications. A pure Swift Package Manager port of the popular [Myanmar Calendar Java library](https://github.com/chanmratekoko/mmcalendar).

For more information about the original project, see [the website](https://chanmratekoko.github.io/mmcalendar/).

## Features

* Convert between Western dates and Myanmar calendar dates
* Support for multiple calendar types (English, Gregorian, Julian)
* Calculate Buddhist Era
* Moon phase calculations
* Multiple language support (English, Myanmar Unicode, Zawgyi, Mon, Tai, Karen)
* Date formatting with customizable patterns, and parsing formatted text back to a date
* Astrological days (yatyaza, pyathada, sabbath, nagahle, mahabote, nakhat and the rest)
* Holidays, anniversaries and substitute business days
* Thingyan (Myanmar New Year) calculations
* Full Swift Package Manager support
* All calculations based on Myanmar Standard Time (UTC+06:30)
* Differential-tested against the [Java reference](https://github.com/chanmratekoko/mmcalendar)
  over 548,501 consecutive days and all 6 languages

## Requirements

- Swift 5.9+
- iOS 15.0+ / macOS 12.0+ / tvOS 15.0+ / watchOS 8.0+

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/saitawngpha/myanmar-calendar.git", from: "1.0.0")
]
```

Or in Xcode:
1. File > Add Package Dependencies
2. Enter the repository URL
3. Select your version requirements

## Usage

### Basic Date Conversion

#### Convert Western Date to Myanmar Date

```swift
import MyanmarCalendar

// Get Myanmar Date from Western date
let myanmarDate = try MyanmarDate.of(year: 2024, month: 1, day: 1)

// Output: 1385
print(myanmarDate.getYearValue())

// Output: Nadaw
print(myanmarDate.getMonthName(.english))

// Output: နတ်တော်
print(myanmarDate.getMonthName(.myanmar))

// Output: Waning
print(myanmarDate.getMoonPhase(.english))

// Output: 5
print(myanmarDate.getFortnightDay(.english))

// Output: Monday
print(myanmarDate.getWeekDay(.english))
```

#### Create Myanmar Date from Current Time

```swift
let now = try MyanmarDate.now()
print("Myanmar Year: \(now.getYear(.english))")
print("Month: \(now.getMonthName(.english))")
```

#### Create Myanmar Date from Foundation Date

```swift
let date = Date()
let myanmarDate = try MyanmarDate.of(date)
print(myanmarDate.description)
```

### Working with Myanmar Dates Directly

```swift
// Create Myanmar date by year, month, and day
let myanmarDate = try MyanmarDate.create(myear: 1385, mmonth: 9, monthDay: 5)

// Or by month name
let myanmarDate2 = try MyanmarDate.create(myear: 1385, myanmarMonthName: "Nadaw", monthDay: 5)
```

### Configuration

Configure default calendar type and language:

```swift
// Default Language: Myanmar Unicode
// Default Calendar Type: English
// You can configure them:

let config = Config(calendarType: .english, language: .myanmar)
Config.initDefault(config)

// Or using the builder pattern
let config = Config.Builder()
    .setCalendarType(.gregorian)
    .setLanguage(.english)
    .build()
Config.initDefault(config)
```

### Date Formatting

Format Myanmar dates with custom patterns:

```swift
let myanmarDate = try MyanmarDate.of(year: 2024, month: 1, day: 1)

// Example formats:
// Output: Sasana Year 2567 Ku, Myanmar Year 1385 Ku, Nadaw Waning 5 Yat Monday Nay
let formatted = myanmarDate.format("S s k, B y k, M p f r E n", .english)

// Output: သာသနာနှစ် ၂၅၆၇ ခု၊ မြန်မာနှစ် ၁၃၈၅ ခု၊ နတ်တော် လဆုတ် ၅ ရက် တနင်္လာနေ့
let myanmarFormatted = myanmarDate.format("S s k, B y k, M p f r En", .myanmar)
```

#### Myanmar Date Format Patterns

| Letter | Component      | Example (English) | Example (Myanmar) |
|--------|----------------|-------------------|-------------------|
| S      | Sasana year    | Sasana Year       | သာသနာနှစ်         |
| s      | Buddhist era   | 2567              | ၂၅၆၇              |
| B      | Burmese year   | Myanmar Year      | မြန်မာနှစ်        |
| y      | Myanmar year   | 1385              | ၁၃၈၅              |
| k      | Ku             | Ku                | ခု                |
| M      | Month          | Nadaw             | နတ်တော်           |
| p      | Moon phase     | Waning            | လဆုတ်             |
| f      | Fortnight day  | 5                 | ၅                 |
| r      | Yat            | Yat               | ရက်               |
| E      | Day name       | Monday            | တနင်္လာ          |
| n      | Nay            | Nay               | နေ့               |

#### Parsing a Formatted Date

```swift
let date = try MyanmarDateParser.parse(
    "Myanmar Year 1385 Ku, Nadaw Waning 5 Yat",
    "B y k, M p f r",
    .english)

// Myanmar Unicode, same pattern
let mm = try MyanmarDateParser.parse(
    "မြန်မာနှစ် ၁၃၈၅ ခု, နတ်တော် လဆုတ် ၅ ရက်",
    "B y k, M p f r",
    .myanmar)
```

The pattern must contain `y` (the Myanmar year); without it there is not enough
information to build a date and the parser throws. On a full moon or new moon the
fortnight day is blank, and the parser fills in 15.

### Converting Back to Western Date

```swift
let myanmarDate = try MyanmarDate.of(year: 2024, month: 4, day: 15)

// Convert to WesternDate
let westernDate = myanmarDate.toWesternDate()
print("Western Date: \(westernDate.year)-\(westernDate.month)-\(westernDate.day)")

// Convert to Foundation Date
if let date = myanmarDate.toDate() {
    print("Foundation Date: \(date)")
}
```

### Language Support

The library supports multiple languages:

```swift
public enum Language {
    case english
    case myanmar     // Unicode Standard (Burmese)
    case zawgyi      // Zawgyi encoding
    case mon         // Mon language
    case tai         // Tai language
    case sgawKaren   // Sgaw Karen language
}

// Example usage:
let myanmarDate = try MyanmarDate.of(year: 2024, month: 1, day: 1)

print(myanmarDate.getMonthName(.english))   // Nadaw
print(myanmarDate.getMonthName(.myanmar))   // နတ်တော်
print(myanmarDate.getWeekDay(.english))     // Monday
print(myanmarDate.getWeekDay(.myanmar))     // တနင်္လာ
```

### Calendar Types

```swift
public enum CalendarType {
    case english    // English calendar
    case gregorian  // Gregorian calendar
    case julian     // Julian calendar
}
```

### Advanced Usage

#### Get Buddhist Era

```swift
let myanmarDate = try MyanmarDate.of(year: 2024, month: 1, day: 1)

// Output: 2567
let buddhistEra = myanmarDate.getBuddhistEraValue()

// Output in Myanmar numerals: ၂၅၆၇
let buddhistEraMyanmar = myanmarDate.getBuddhistEra(.myanmar)
```

#### Astrological Days

```swift
let myanmarDate = try MyanmarDate.of(year: 2024, month: 1, day: 1)
let astro = Astro.of(myanmarDate)

astro.isSabbath              // Bool
astro.getSabbathOrEve()      // "Sabbath", "Sabbath Eve" or ""
astro.getAstrologicalDay()   // "Yatyaza", "Pyathada", "Afternoon Pyathada" or ""
astro.getNagahle(.english)   // "West" | "North" | "East" | "South"
astro.getMahabote(.english)  // "Binga" ... "Puti"
astro.getNakhat(.english)    // "Ogre" | "Elf" | "Human"
astro.getYearName(.english)  // e.g. "Hpusha"
print(astro.toString(.myanmar))
```

#### Date Arithmetic and Comparison

```swift
let date = try MyanmarDate.of(year: 2024, month: 1, day: 1)

let nextWeek = try date.plusDays(7)
let lastWeek = try date.minusDays(7)

date.isBefore(nextWeek)      // true
date.isAfter(lastWeek)       // true
date.hasSameDay(nextWeek)    // false
date.isWeekend()             // false (a Monday)
date.getMnt(.english)        // "Late" / "Second" qualifier, or ""
```

#### Holidays and Anniversaries

```swift
let date = try MyanmarDate.of(year: 2024, month: 1, day: 4)

HolidayCalculator.getHoliday(date)                       // configured language
HolidayCalculator.getHoliday(date, .myanmar)             // ["လွတ်လပ်ရေး နေ့"]
HolidayCalculator.isHoliday(date)                        // true
HolidayCalculator.getAnniversary(date, .english)
BusinessDayCalculator.substituteBusinessDay(2026, 1, 10) // ["Business Day"]
```

#### Using the Kernels Directly

```swift
let jdn = MyanmarDateKernel.myanmarDateToJulian(1385, 9, 5)
let date = try MyanmarDateKernel.julianToMyanmarDate(Double(jdn))

MyanmarDateKernel.checkWatat(1385)["watat"]          // 1
MyanmarCalendarKernel.calculateYearType(1385)        // 0, 1 or 2
WesternDateKernel.getLengthOfMonth(2024, 2, 0)       // 29
AstroKernel.calculateSabbath(0, 9, 8)                // 1
MyanmarYearConstants.getMyConst(1385).eraId          // 3.0
```

#### Working with Western Dates

```swift
// Create WesternDate
let westernDate = WesternDate(year: 2024, month: 4, day: 15)

// Convert to Myanmar Date
let myanmarDate = try westernDate.toMyanmarDate()

// Convert to Foundation Date
if let date = westernDate.toDate() {
    print("Foundation Date: \(date)")
}

// Create from Foundation Date
let now = Date()
let western = WesternDate.from(now)
```

## Testing

Run the test suite:

```bash
swift test
```

## Credits

This Swift package is a port of the [Myanmar Calendar Java library](https://github.com/chanmratekoko/mmcalendar) by [Chan Mrate Ko Ko](https://github.com/chanmratekoko).

The original algorithm is based on:
- [Algorithm, Program and Calculation of Myanmar Calendar](http://cool-emerald.blogspot.sg/2013/06/algorithm-program-and-calculation-of.html) by [Dr Yan Naing Aye](https://github.com/yan9a/)

Language translations credits:
- Mon: ITVilla, proofread by Mikau Nyan
- Tai: Jao Tai Num, [Tai Dictionary](https://www.taidictionary.com/)

## Algorithm Notes

All calculations are based on Myanmar Standard Time (UTC+06:30) which is calculated on the basis of 97° 30' longitude.

The algorithm is capable of calculating from the commencement of the Myanmar Calendar Year 2 up to year 1500.

## License

```
MIT License

Copyright (c) 2017 Chan Mrate Ko Ko
Copyright (c) 2025-2026 Sai Tawng Pha

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---

This library is a Swift port of mmcalendar
(https://github.com/chanmratekoko/mmcalendar) by Chan Mrate Ko Ko, which is
distributed under the MIT License. The underlying Myanmar calendar algorithm
is by Dr. Yan Naing Aye.
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Changelog

### Version 1.1.0
- Verified against the Java reference by differential testing; fixed a holiday
  operator-precedence bug affecting 2018-2021, a wrong substitute business day,
  and a missing moon-phase guard on the fortnight day
- Rewrote `LanguageTranslator` as a faithful port: full catalog, direct maps and a
  trie for longest-prefix sentence translation, in all 6 languages and both directions
- Added `MyanmarDateParser`, `MyanmarDateFormat` and `MyanmarEraConstants`
- Made the kernels public: `MyanmarDateKernel`, `WesternDateKernel`, `AstroKernel`,
  `BinarySearchUtil`, `MyanmarYearConstants`
- Added the remaining `MyanmarDate` API (`getMnt`, `isWeekend`, `plusDays`,
  `minusDays`, `isBefore`, `isAfter`, `hasSameDay`, `toString(_:)`, western date
  validation, and the moon-phase/fortnight-day `create` overloads)
- Added `Astro`'s localized getters and `toString(_:)`

### Version 1.0.0
- Initial Swift Package Manager release
- Core date conversion functionality
- Multiple language support
- Date formatting
- Comprehensive test coverage
