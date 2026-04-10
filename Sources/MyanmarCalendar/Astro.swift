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

    // Convenience boolean properties
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
}
