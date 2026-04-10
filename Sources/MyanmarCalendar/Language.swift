import Foundation

/// Representing different languages and their corresponding punctuation marks.
public enum Language: Int, CaseIterable {
    case english = 0
    case myanmar = 1
    case zawgyi = 2
    case mon = 3
    case tai = 4
    case sgawKaren = 5

    /// The index of the language
    public var languageIndex: Int {
        return self.rawValue
    }

    /// The punctuation mark used in the language for separation
    public var punctuationMark: String {
        switch self {
        case .english:
            return ", "
        case .myanmar, .zawgyi, .mon, .tai, .sgawKaren:
            return "၊ "
        }
    }

    /// The punctuation mark used in the language for ending a sentence
    public var punctuation: String {
        switch self {
        case .english:
            return "."
        case .myanmar, .zawgyi, .mon, .tai, .sgawKaren:
            return "။ "
        }
    }
}
