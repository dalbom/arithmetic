import Foundation

struct GeneratedProblem: Identifiable {
    let id = UUID()
    let operands: [Int]
    let operation: OperationType
    let problemNumber: Int

    /// The display string for the problem, e.g. "23 + 45 ="
    var displayString: String {
        let nums = operands.map { String($0) }
        return nums.joined(separator: " \(operation.symbol) ") + " ="
    }

    /// The computed answer
    var answer: Int {
        guard !operands.isEmpty else { return 0 }
        var result = operands[0]
        for i in 1..<operands.count {
            switch operation {
            case .addition:
                result += operands[i]
            case .subtraction:
                result -= operands[i]
            case .multiplication:
                result *= operands[i]
            case .division:
                guard operands[i] != 0 else { return 0 }
                result /= operands[i]
            }
        }
        return result
    }

    /// Display string with answer filled in
    var answerDisplayString: String {
        let nums = operands.map { String($0) }
        return nums.joined(separator: " \(operation.symbol) ") + " = \(answer)"
    }
}
