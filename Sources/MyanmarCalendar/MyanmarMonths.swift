import Foundation

/// Myanmar Months List for Specific Myanmar Year
public struct MyanmarMonths {

    public let monthList: [Int]
    public let monthNameList: [String]
    public let calculationMonth: Int

    internal init(monthList: [Int], monthNameList: [String], calculationMonth: Int) {
        self.monthList = monthList
        self.monthNameList = monthNameList
        self.calculationMonth = calculationMonth
    }

    /// Calculate related Myanmar month names by year
    /// - Parameters:
    ///   - myear: Myanmar Year
    ///   - mmonth: Myanmar month [Tagu=1, Kason=2, Nayon=3, 1st Waso=0, (2nd) Waso=4, etc.]
    /// - Returns: MyanmarMonths object
    public static func of(myear: Int, mmonth: Int) throws -> MyanmarMonths {
        return try MyanmarCalendarKernel.calculateRelatedMyanmarMonths(myear, mmonth)
    }

    /// Get month names in specified language
    /// - Parameter language: Target language
    /// - Returns: Array of month names
    public func getMonthNameList(_ language: Language = .english) -> [String] {
        if language == .english {
            return monthNameList
        }
        return monthNameList.map { monthName in
            LanguageTranslator.translateSentence(monthName, .english, language)
        }
    }

    /// Get calculation month name
    /// - Returns: Current month name
    public func getCalculationMonthName() -> String {
        if let index = monthList.firstIndex(of: calculationMonth), index < monthNameList.count {
            return monthNameList[index]
        }
        return ""
    }

    /// Get calculation month index
    /// - Returns: Index in the month list
    public func getCalculationMonthIndex() -> Int {
        return monthList.firstIndex(of: calculationMonth) ?? -1
    }
}

extension MyanmarMonths: CustomStringConvertible {
    public var description: String {
        return "MyanmarMonths(monthList: \(monthList), monthNameList: \(monthNameList), calculationMonth: \(calculationMonth))"
    }
}
