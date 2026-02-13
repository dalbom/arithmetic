import SwiftUI

enum OperationType: String, Codable, CaseIterable, Identifiable {
    case addition
    case subtraction
    case multiplication
    case division

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .addition: return "+"
        case .subtraction: return "-"
        case .multiplication: return "×"
        case .division: return "÷"
        }
    }

    var localizedName: LocalizedStringKey {
        switch self {
        case .addition: return "addition"
        case .subtraction: return "subtraction"
        case .multiplication: return "multiplication"
        case .division: return "division"
        }
    }

    var supportsEasyMode: Bool {
        switch self {
        case .subtraction, .division: return true
        default: return false
        }
    }

    var supportsCarryControl: Bool {
        switch self {
        case .addition, .subtraction: return true
        default: return false
        }
    }

    /// Whether this operation is a Pro-only feature
    var requiresPro: Bool {
        switch self {
        case .multiplication, .division: return true
        default: return false
        }
    }

    /// Color associated with this operation type for UI theming
    var themeColorName: String {
        switch self {
        case .addition: return "AdditionGreen"
        case .subtraction: return "SubtractionPink"
        case .multiplication: return "MultiplicationBlue"
        case .division: return "DivisionOrange"
        }
    }
}
