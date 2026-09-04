import Foundation

/// Astrological information for Myanmar Date
public struct Astro {

    public let sabbath: Int
    public let yatyaza: Int
    public let pyathada: Int
    public let thamanyo: Int
    public let amyeittasote: Int
    public let warameittugyi: Int
    public let warameittunge: Int
    public let yatpote: Int
    public let thamaphyu: Int
    public let nagapor: Int
    public let yatyotema: Int
    public let mahayatkyan: Int
    public let shanyat: Int
    public let nagahle: Int // [0=west, 1=north, 2=east, 3=south]
    public let mahabote: Int // [0=Binga, 1=Atun, 2=Yaza, 3=Adipati, 4=Marana, 5=Thike, 6=Puti]
    public let nakhat: Int // [0=Ogre, 1=Elf, 2=Human]
    public let yearName: Int

    private init(sabbath: Int, yatyaza: Int, pyathada: Int, thamanyo: Int,
                 amyeittasote: Int, warameittugyi: Int, warameittunge: Int,
                 yatpote: Int, thamaphyu: Int, nagapor: Int, yatyotema: Int,
                 mahayatkyan: Int, shanyat: Int, nagahle: Int, mahabote: Int,
                 nakhat: Int, yearName: Int) {
        self.sabbath = sabbath
        self.yatyaza = yatyaza
        self.pyathada = pyathada
        self.thamanyo = thamanyo
        self.amyeittasote = amyeittasote
        self.warameittugyi = warameittugyi
        self.warameittunge = warameittunge
        self.yatpote = yatpote
        self.thamaphyu = thamaphyu
        self.nagapor = nagapor
        self.yatyotema = yatyotema
        self.mahayatkyan = mahayatkyan
        self.shanyat = shanyat
        self.nagahle = nagahle
        self.mahabote = mahabote
        self.nakhat = nakhat
        self.yearName = yearName
    }

    /// Myanmar Date to Astro
    public static func of(_ myanmarDate: MyanmarDate) -> Astro {
        let myear = myanmarDate.myear
        let yearType = myanmarDate.yearType
        let mmonth = myanmarDate.mmonth
        let monthDay = myanmarDate.monthDay
        let weekDay = myanmarDate.weekDay

        return Astro(
            sabbath: AstroKernel.calculateSabbath(yearType, mmonth, monthDay),
            yatyaza: AstroKernel.calculateYatyaza(mmonth, weekDay),
            pyathada: AstroKernel.calculatePyathada(mmonth, weekDay),
            thamanyo: AstroKernel.calculateThamanyo(mmonth, weekDay),
            amyeittasote: AstroKernel.calculateAmyeittasote(monthDay, weekDay),
            warameittugyi: AstroKernel.calculateWarameittugyi(monthDay, weekDay),
            warameittunge: AstroKernel.calculateWarameittunge(monthDay, weekDay),
            yatpote: AstroKernel.calculateYatpote(monthDay, weekDay),
            thamaphyu: AstroKernel.calculateThamaphyu(monthDay, weekDay),
            nagapor: AstroKernel.calculateNagapor(monthDay, weekDay),
            yatyotema: AstroKernel.calculateYatyotema(mmonth, monthDay),
            mahayatkyan: AstroKernel.calculateMahayatkyan(mmonth, monthDay),
            shanyat: AstroKernel.calculateShanyat(mmonth, monthDay),
            nagahle: AstroKernel.calculateNagahle(mmonth),
            mahabote: AstroKernel.calculateMahabote(myear, weekDay),
            nakhat: AstroKernel.calculateNakhat(myear),
            yearName: AstroKernel.calculateYearName(myear)
        )
    }

    // MARK: - Convenience boolean properties

    public var isYatyaza: Bool { yatyaza > 0 }
    public var isPyathada: Bool { pyathada > 0 }
    public var isSabbath: Bool { sabbath == 1 }
    public var isSabbathEve: Bool { sabbath == 2 }
    public var isThamanyo: Bool { thamanyo > 0 }
    public var isAmyeittasote: Bool { amyeittasote > 0 }
    public var isWarameittugyi: Bool { warameittugyi > 0 }
    public var isWarameittunge: Bool { warameittunge > 0 }
    public var isYatpote: Bool { yatpote > 0 }
    public var isThamaphyu: Bool { thamaphyu > 0 }
    public var isNagapor: Bool { nagapor > 0 }
    public var isYatyotema: Bool { yatyotema > 0 }
    public var isMahayatkyan: Bool { mahayatkyan > 0 }
    public var isShanyat: Bool { shanyat > 0 }

    // MARK: - Raw values

    /// [0 = none, 1 = sabbath, 2 = sabbath eve]
    public func getSabbathValue() -> Int { sabbath }

    /// [0 = none, 1 = Pyathada, 2 = Afternoon Pyathada]
    public func getPyathadaValue() -> Int { pyathada }

    /// [0=west, 1=north, 2=east, 3=south]
    public func getNagahleValue() -> Int { nagahle }

    /// [0=Binga, 1=Atun, 2=Yaza, 3=Adipati, 4=Marana, 5=Thike, 6=Puti]
    public func getMahaboteValue() -> Int { mahabote }

    /// [0=Ogre, 1=Elf, 2=Human]
    public func getNakhatValue() -> Int { nakhat }

    // MARK: - Localized names

    private static let nagahleNames = ["West", "North", "East", "South"]
    private static let mahaboteNames = ["Binga", "Atun", "Yaza", "Adipati", "Marana", "Thike", "Puti"]
    private static let nakhatNames = ["Ogre", "Elf", "Human"]
    private static let yearNames = [
        "Hpusha", "Magha", "Phalguni", "Chitra",
        "Visakha", "Jyeshtha", "Ashadha", "Sravana",
        "Bhadrapaha", "Asvini", "Krittika", "Mrigasiras"
    ]

    private func name(_ flag: Bool, _ key: String, _ language: Language) -> String {
        return flag ? LanguageTranslator.translate(key, language) : ""
    }

    /// "Yatyaza" or empty
    public func getYatyaza(_ language: Language = Config.getInstance().language) -> String {
        return name(isYatyaza, "Yatyaza", language)
    }

    /// "Pyathada", "Afternoon Pyathada" or empty
    public func getPyathada(_ language: Language = Config.getInstance().language) -> String {
        if pyathada == 1 {
            return LanguageTranslator.translate("Pyathada", language)
        } else if pyathada == 2 {
            return LanguageTranslator.translate("Afternoon", language)
                + " " + LanguageTranslator.translate("Pyathada", language)
        }
        return ""
    }

    /// "Yatyaza", "Pyathada"/"Afternoon Pyathada", both, or empty
    public func getAstrologicalDay(_ language: Language = Config.getInstance().language) -> String {
        var result = getYatyaza(language)

        if isYatyaza && isPyathada {
            result += "၊ "
        }

        result += getPyathada(language)
        return result
    }

    /// "Sabbath" or empty
    public func getSabbath(_ language: Language = Config.getInstance().language) -> String {
        return sabbath == 1 ? LanguageTranslator.translate("Sabbath", language) : ""
    }

    /// "Sabbath Eve" or empty
    public func getSabbathEve(_ language: Language = Config.getInstance().language) -> String {
        return sabbath == 2 ? LanguageTranslator.translate("Sabbath Eve", language) : ""
    }

    /// "Sabbath", "Sabbath Eve" or empty
    public func getSabbathOrEve(_ language: Language = Config.getInstance().language) -> String {
        if sabbath == 1 {
            return LanguageTranslator.translate("Sabbath", language)
        } else if sabbath == 2 {
            return LanguageTranslator.translate("Sabbath Eve", language)
        }
        return ""
    }

    /// "Thamanyo" or empty
    public func getThamanyo(_ language: Language = Config.getInstance().language) -> String {
        return name(isThamanyo, "Thamanyo", language)
    }

    /// "Amyeittasote" or empty
    public func getAmyeittasote(_ language: Language = Config.getInstance().language) -> String {
        return name(isAmyeittasote, "Amyeittasote", language)
    }

    /// "Warameittugyi" or empty
    public func getWarameittugyi(_ language: Language = Config.getInstance().language) -> String {
        return name(isWarameittugyi, "Warameittugyi", language)
    }

    /// "Warameittunge" or empty
    public func getWarameittunge(_ language: Language = Config.getInstance().language) -> String {
        return name(isWarameittunge, "Warameittunge", language)
    }

    /// "Yatpote" or empty
    public func getYatpote(_ language: Language = Config.getInstance().language) -> String {
        return name(isYatpote, "Yatpote", language)
    }

    /// "Thamaphyu" or empty
    public func getThamaphyu(_ language: Language = Config.getInstance().language) -> String {
        return name(isThamaphyu, "Thamaphyu", language)
    }

    /// "Nagapor" or empty
    public func getNagapor(_ language: Language = Config.getInstance().language) -> String {
        return name(isNagapor, "Nagapor", language)
    }

    /// "Yatyotema" or empty
    public func getYatyotema(_ language: Language = Config.getInstance().language) -> String {
        return name(isYatyotema, "Yatyotema", language)
    }

    /// "Mahayatkyan" or empty
    public func getMahayatkyan(_ language: Language = Config.getInstance().language) -> String {
        return name(isMahayatkyan, "Mahayatkyan", language)
    }

    /// "Shanyat" or empty
    public func getShanyat(_ language: Language = Config.getInstance().language) -> String {
        return name(isShanyat, "Shanyat", language)
    }

    /// Nagahle direction ["West", "North", "East", "South"]
    public func getNagahle(_ language: Language = Config.getInstance().language) -> String {
        return LanguageTranslator.translate(Astro.nagahleNames[nagahle], language)
    }

    /// Mahabote ["Binga", "Atun", "Yaza", "Adipati", "Marana", "Thike", "Puti"]
    public func getMahabote(_ language: Language = Config.getInstance().language) -> String {
        return LanguageTranslator.translate(Astro.mahaboteNames[mahabote], language)
    }

    /// Nakhat ["Ogre", "Elf", "Human"]
    public func getNakhat(_ language: Language = Config.getInstance().language) -> String {
        return LanguageTranslator.translate(Astro.nakhatNames[nakhat], language)
    }

    /// Myanmar year name
    public func getYearName(_ language: Language = Config.getInstance().language) -> String {
        return LanguageTranslator.translate(Astro.yearNames[yearName], language)
    }

    // MARK: - Description

    /// Full astrological description.
    ///
    /// Mirrors the Java `Astro.toString(Language)`, including its quirk that the leading
    /// astrological day and the trailing year name are rendered in the *configured*
    /// language rather than the `language` argument.
    public func toString(_ language: Language = Config.getInstance().language) -> String {
        var result = getAstrologicalDay()
        let mark = language.punctuationMark

        if isSabbath || isSabbathEve {
            result += mark + getSabbath(language)
        }
        if isThamanyo {
            result += " " + mark + getThamanyo(language)
        }
        if isThamaphyu {
            result += " " + mark + getThamaphyu(language)
        }
        if isAmyeittasote {
            result += " " + mark + getAmyeittasote(language)
        }
        if isWarameittugyi {
            result += " " + mark + getWarameittugyi(language)
        }
        if isWarameittunge {
            result += " " + mark + getWarameittunge(language)
        }
        if isYatpote {
            result += " " + mark + getYatpote(language)
        }
        if isNagapor {
            result += " " + mark + getNagapor()
        }
        if isYatyotema {
            result += " " + mark + getYatyotema(language)
        }
        if isMahayatkyan {
            result += " " + mark + getMahayatkyan(language)
        }
        if isShanyat {
            result += " " + mark + getShanyat(language)
        }

        result += " " + mark
            + LanguageTranslator.translate("Naga", language) + " "
            + LanguageTranslator.translate("Head", language) + " "
            + getNagahle(language) + " "
            + LanguageTranslator.translate("Facing", language)

        result += " " + mark
        result += getMahabote(language) + LanguageTranslator.translate("Born", language)

        result += " " + mark
        result += getNakhat(language) + " " + LanguageTranslator.translate("Nakhat", language)

        result += " " + mark
        result += getYearName()

        return result
    }
}

extension Astro: CustomStringConvertible {
    public var description: String {
        return toString()
    }
}

extension Astro: Equatable {}
