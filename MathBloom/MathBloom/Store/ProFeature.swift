import SwiftUI

enum ProFeature: String, CaseIterable, Identifiable {
    case multiplication
    case division
    case extendedDigits       // 3-5 digit operands
    case multipleOperands     // 3-5 operands
    case extendedPages        // 4-100 pages
    case unlimitedPresets     // More than 2 saved presets
    case carryControl         // Carry/borrow control
    case answerKey            // Answer key generation
    case customHeader         // Child name, school name
    case latexPDF             // LaTeX-quality PDF via TeXLive
    case iCloudSync           // iCloud sync for presets
    case noBranding           // Remove "Made with 산수해봄" footer

    var id: String { rawValue }

    var localizedName: LocalizedStringKey {
        switch self {
        case .multiplication: return "pro_multiplication"
        case .division: return "pro_division"
        case .extendedDigits: return "pro_extended_digits"
        case .multipleOperands: return "pro_multiple_operands"
        case .extendedPages: return "pro_extended_pages"
        case .unlimitedPresets: return "pro_unlimited_presets"
        case .carryControl: return "pro_carry_control"
        case .answerKey: return "pro_answer_key"
        case .customHeader: return "pro_custom_header"
        case .latexPDF: return "pro_latex_pdf"
        case .iCloudSync: return "pro_icloud_sync"
        case .noBranding: return "pro_no_branding"
        }
    }

    var localizedDescription: LocalizedStringKey {
        switch self {
        case .multiplication: return "pro_multiplication_desc"
        case .division: return "pro_division_desc"
        case .extendedDigits: return "pro_extended_digits_desc"
        case .multipleOperands: return "pro_multiple_operands_desc"
        case .extendedPages: return "pro_extended_pages_desc"
        case .unlimitedPresets: return "pro_unlimited_presets_desc"
        case .carryControl: return "pro_carry_control_desc"
        case .answerKey: return "pro_answer_key_desc"
        case .customHeader: return "pro_custom_header_desc"
        case .latexPDF: return "pro_latex_pdf_desc"
        case .iCloudSync: return "pro_icloud_sync_desc"
        case .noBranding: return "pro_no_branding_desc"
        }
    }

    var iconName: String {
        switch self {
        case .multiplication: return "multiply"
        case .division: return "divide"
        case .extendedDigits: return "number"
        case .multipleOperands: return "plus.forwardslash.minus"
        case .extendedPages: return "doc.on.doc"
        case .unlimitedPresets: return "bookmark.fill"
        case .carryControl: return "arrow.up.arrow.down"
        case .answerKey: return "checkmark.circle"
        case .customHeader: return "person.text.rectangle"
        case .latexPDF: return "doc.richtext"
        case .iCloudSync: return "icloud"
        case .noBranding: return "eye.slash"
        }
    }
}
