import Foundation

extension Int {
    /// Generate a random integer with exactly the specified number of digits
    static func randomWithDigits(_ digits: Int) -> Int {
        guard digits >= 1 else { return 0 }
        if digits == 1 {
            return Int.random(in: 1...9)
        }
        let minVal = Int(pow(10.0, Double(digits - 1)))
        let maxVal = Int(pow(10.0, Double(digits))) - 1
        return Int.random(in: minVal...maxVal)
    }

    /// Number of digits in this integer
    var digitCount: Int {
        if self == 0 { return 1 }
        return String(abs(self)).count
    }
}
