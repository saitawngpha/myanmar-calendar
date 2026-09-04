import Foundation

/// Binary Search Utility
public struct BinarySearchUtil {

    private init() {}

    /// Search first dimension in a 2D array
    /// - Parameters:
    ///   - key: search key
    ///   - array: search in array
    /// - Returns: index or -1 if not found
    public static func search(_ key: Double, _ array: [[Int]]) -> Int {
        var l = 0
        var u = array.count - 1

        while u >= l {
            let i = Int(floor(Double(l + u) / 2.0))
            if Double(array[i][0]) > key {
                u = i - 1
            } else if Double(array[i][0]) < key {
                l = i + 1
            } else {
                return i
            }
        }
        return -1
    }

    /// Search first dimension in a 1D array
    /// - Parameters:
    ///   - key: search key
    ///   - array: search in array
    /// - Returns: index or -1 if not found
    public static func search(_ key: Double, _ array: [Int]) -> Int {
        var l = 0
        var u = array.count - 1

        while u >= l {
            let i = Int(floor(Double(l + u) / 2.0))
            if Double(array[i]) > key {
                u = i - 1
            } else if Double(array[i]) < key {
                l = i + 1
            } else {
                return i
            }
        }
        return -1
    }
}
