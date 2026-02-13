import Foundation

final class ArithmeticEngine {

    /// Generate a random number with exactly the specified number of digits
    static func generateNumber(digits: Int) -> Int {
        guard digits >= 1 else { return 0 }
        if digits == 1 {
            return Int.random(in: 1...9)
        }
        let minVal = Int(pow(10.0, Double(digits - 1)))
        let maxVal = Int(pow(10.0, Double(digits))) - 1
        return Int.random(in: minVal...maxVal)
    }

    /// Generate a single problem based on configuration
    static func generateProblem(config: ProblemConfig, number: Int) -> GeneratedProblem {
        let operands = generateOperands(config: config)
        return GeneratedProblem(
            operands: operands,
            operation: config.type,
            problemNumber: number
        )
    }

    /// Generate operands respecting easy mode and carry control
    private static func generateOperands(config: ProblemConfig) -> [Int] {
        let maxAttempts = 100

        for _ in 0..<maxAttempts {
            var nums = config.operandDigits.map { generateNumber(digits: $0) }

            switch config.type {
            case .addition:
                if checkCarryControl(nums: nums, config: config) {
                    return nums
                }

            case .subtraction:
                if config.easyMode && nums.count == 2 {
                    // Sort descending so result is non-negative
                    nums.sort(by: >)
                }
                if config.easyMode && nums.count > 2 {
                    // For 3+ operands, ensure running total never goes negative
                    // Put largest first, sort rest ascending
                    let sorted = nums.sorted(by: >)
                    nums = sorted
                    var running = nums[0]
                    var valid = true
                    for i in 1..<nums.count {
                        running -= nums[i]
                        if running < 0 { valid = false; break }
                    }
                    if !valid { continue }
                }
                if checkCarryControl(nums: nums, config: config) {
                    return nums
                }

            case .multiplication:
                return nums

            case .division:
                if config.easyMode {
                    // For easy mode division: generate divisor and quotient, compute dividend
                    if nums.count == 2 {
                        let divisor = nums[0]
                        let quotient = nums[1]
                        guard divisor != 0 else { continue }
                        let dividend = divisor * quotient
                        return [dividend, divisor]
                    } else {
                        // For 3+ operands in easy division: chain so each division is exact
                        // Start with a product of all subsequent operands times a quotient
                        let divisors = Array(nums.dropFirst())
                        guard !divisors.contains(0) else { continue }
                        let baseQuotient = generateNumber(digits: max(1, config.operandDigits[0]))
                        var dividend = baseQuotient
                        for d in divisors {
                            dividend *= d
                        }
                        let result = [dividend] + divisors
                        return result
                    }
                } else {
                    guard !nums.dropFirst().contains(0) else { continue }
                    return nums
                }
            }
        }

        // Fallback: return simple operands
        return config.operandDigits.map { generateNumber(digits: $0) }
    }

    /// Check carry/borrow control constraints
    private static func checkCarryControl(nums: [Int], config: ProblemConfig) -> Bool {
        guard config.carryControl != .none else { return true }

        switch config.type {
        case .addition:
            let hasCarry = additionHasCarry(nums)
            switch config.carryControl {
            case .requireCarry: return hasCarry
            case .preventCarry: return !hasCarry
            case .none: return true
            }
        case .subtraction:
            guard nums.count >= 2 else { return true }
            let hasBorrow = subtractionHasBorrow(nums[0], nums[1])
            switch config.carryControl {
            case .requireCarry: return hasBorrow
            case .preventCarry: return !hasBorrow
            case .none: return true
            }
        default:
            return true
        }
    }

    /// Check if adding the numbers produces a carry in any column
    static func additionHasCarry(_ nums: [Int]) -> Bool {
        let maxDigits = String(nums.max() ?? 0).count
        for col in 0..<maxDigits {
            let divisor = Int(pow(10.0, Double(col)))
            let columnSum = nums.reduce(0) { $0 + ($1 / divisor) % 10 }
            if columnSum >= 10 { return true }
        }
        return false
    }

    /// Check if subtracting b from a requires borrowing
    static func subtractionHasBorrow(_ a: Int, _ b: Int) -> Bool {
        let maxLen = max(String(a).count, String(b).count)
        let aDigits = String(String(a).reversed()).map { Int(String($0))! }
        let bDigits = String(String(b).reversed()).map { Int(String($0))! }

        for col in 0..<maxLen {
            let aDigit = col < aDigits.count ? aDigits[col] : 0
            let bDigit = col < bDigits.count ? bDigits[col] : 0
            if aDigit < bDigit { return true }
        }
        return false
    }

    /// Generate a full worksheet with all pages
    static func generateWorksheet(config: WorksheetConfig) -> GeneratedWorksheet {
        var pages: [GeneratedPage] = []

        for pageIndex in 0..<config.numberOfPages {
            let pageNumber = config.pageOffset + pageIndex

            // Build problem configs for this page
            var pageProblems: [(config: ProblemConfig, count: Int)] = []
            for problemConfig in config.problems {
                pageProblems.append((config: problemConfig, count: problemConfig.questionsPerPage))
            }

            // Generate all problems for the page
            var allProblems: [GeneratedProblem] = []
            var problemNumber = 1

            // Create expanded list and shuffle
            var expandedConfigs: [ProblemConfig] = []
            for (pConfig, count) in pageProblems {
                expandedConfigs.append(contentsOf: Array(repeating: pConfig, count: count))
            }
            expandedConfigs.shuffle()

            for pConfig in expandedConfigs {
                let problem = generateProblem(config: pConfig, number: problemNumber)
                allProblems.append(problem)
                problemNumber += 1
            }

            pages.append(GeneratedPage(pageNumber: pageNumber, problems: allProblems))
        }

        return GeneratedWorksheet(pages: pages, config: config)
    }
}
