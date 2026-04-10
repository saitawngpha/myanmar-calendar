import Foundation

/// Configuration For Calendar
public final class Config {

    public let calendarType: CalendarType
    public let language: Language

    private static var instance: Config?

    /// Set the default Calendar Config
    /// - Parameter config: the config instance
    public static func initDefault(_ config: Config) {
        instance = config
    }

    /// The current Calendar Config.
    /// If not set it will create a default config.
    /// - Returns: the current Calendar Config
    public static func getInstance() -> Config {
        if instance == nil {
            instance = Config()
        }
        return instance!
    }

    /// Initialize with builder
    private init(builder: Builder) {
        self.calendarType = builder.calendarType
        self.language = builder.language
    }

    /// Initialize with default values
    public init(calendarType: CalendarType = .english, language: Language = .myanmar) {
        self.calendarType = calendarType
        self.language = language
    }

    /// Builder pattern for Config
    public class Builder {
        var calendarType: CalendarType = .english
        var language: Language = .myanmar

        public init() {}

        @discardableResult
        public func setCalendarType(_ calendarType: CalendarType) -> Builder {
            self.calendarType = calendarType
            return self
        }

        @discardableResult
        public func setLanguage(_ language: Language) -> Builder {
            self.language = language
            return self
        }

        public func build() -> Config {
            return Config(builder: self)
        }
    }
}
