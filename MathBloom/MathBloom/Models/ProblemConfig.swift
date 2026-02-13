import Foundation

struct ProblemConfig: Codable, Identifiable, Hashable {
    var id = UUID()
    var type: OperationType = .addition
    /// Number of digits for each operand. Array length = number of operands (2-5).
    var operandDigits: [Int] = [1, 1]
    var questionsPerPage: Int = 10
    var easyMode: Bool = false

    /// Carry/borrow control (Pro feature)
    enum CarryControl: String, Codable {
        case none        // No control
        case requireCarry  // Force carry/borrow
        case preventCarry  // Prevent carry/borrow
    }
    var carryControl: CarryControl = .none

    /// Number of operands (derived from operandDigits count)
    var operandCount: Int {
        operandDigits.count
    }

    /// Add an operand with given digits
    mutating func addOperand(digits: Int = 1) {
        guard operandDigits.count < 5 else { return }
        operandDigits.append(digits)
    }

    /// Remove last operand (minimum 2)
    mutating func removeLastOperand() {
        guard operandDigits.count > 2 else { return }
        operandDigits.removeLast()
    }
}
