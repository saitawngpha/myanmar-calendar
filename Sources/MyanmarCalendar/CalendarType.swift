import Foundation

/// Support Calendar Type
public enum CalendarType: Int, CaseIterable {
    case english = 0
    case gregorian = 1
    case julian = 2

    /// The label of the calendar type
    public var label: String {
        switch self {
        case .english:
            return "English"
        case .gregorian:
            return "Gregorian"
        case .julian:
            return "Julian"
        }
    }

    /// The numeric value of the calendar type
    public var number: Int {
        return self.rawValue
    }
}
