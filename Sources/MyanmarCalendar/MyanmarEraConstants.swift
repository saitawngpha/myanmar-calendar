import Foundation

/// Typed value type for Myanmar calendar era constants.
///
/// Port of the Java `mmcalendar.MyanmarEraConstants`, which replaced the
/// stringly-typed `Map<String, Double>` returned by `MyanmarYearConstants`.
public struct MyanmarEraConstants: Equatable {

    /// Myanmar calendar era id [1.1, 1.2, 1.3, 2, 3]
    public let eraId: Double

    /// Watat offset to compensate
    public let watatOffset: Double

    /// Number of months to find excess days
    public let numberOfMonths: Double

    /// Exception in watat year [0=normal, 1=exception]
    public let exceptionInWatatYear: Double

    init(eraId: Double, watatOffset: Double, numberOfMonths: Double, exceptionInWatatYear: Double) {
        self.eraId = eraId
        self.watatOffset = watatOffset
        self.numberOfMonths = numberOfMonths
        self.exceptionInWatatYear = exceptionInWatatYear
    }
}

extension MyanmarEraConstants: CustomStringConvertible {
    public var description: String {
        return "MyanmarEraConstants{eraId=\(eraId), watatOffset=\(watatOffset), "
            + "numberOfMonths=\(numberOfMonths), exceptionInWatatYear=\(exceptionInWatatYear)}"
    }
}
