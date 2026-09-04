import Foundation

/// Business Day Calculator
/// Calculates substitute business days for Myanmar
public struct BusinessDayCalculator {

    /// Get substitute business day
    /// - Parameters:
    ///   - gy: Gregorian year
    ///   - gm: month [1-12]
    ///   - gd: day [1-31]
    /// - Returns: List of business day strings
    public static func substituteBusinessDay(_ gy: Int, _ gm: Int, _ gd: Int) -> [String] {
        var businessDay: [String] = []

        // Update For 2025 Calendar Year
        if (gy == 2025 && gm == 1 && gd == 11)
            || (gy == 2025 && gm == 3 && (gd == 22 || gd == 29))
            || (gy == 2025 && gm == 11 && gd == 8)
            || (gy == 2026 && gm == 1 && gd == 10) {
            businessDay.append("Business Day")
        }

        return businessDay
    }
}
