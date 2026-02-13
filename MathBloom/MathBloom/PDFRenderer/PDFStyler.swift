import UIKit

struct PDFStyle {
    let fontSize: CGFloat
    let lineSpacing: CGFloat // vertical space between problems in points
    let font: UIFont
    let numberFont: UIFont // Monospaced digit font for alignment

    /// Get style based on total questions per page (matching Python logic)
    /// Python: ≤20 → Large/0.8cm, ≤30 → large/0.5cm, ≤40 → normal/0.3cm, >40 → small/0.2cm
    static func forQuestionCount(_ count: Int) -> PDFStyle {
        let fontSize: CGFloat
        let lineSpacing: CGFloat

        if count <= 20 {
            fontSize = 16.0 // Large
            lineSpacing = 22.68 // 0.8cm
        } else if count <= 30 {
            fontSize = 14.0 // large
            lineSpacing = 14.17 // 0.5cm
        } else if count <= 40 {
            fontSize = 12.0 // normal
            lineSpacing = 8.50 // 0.3cm
        } else {
            fontSize = 10.0 // small
            lineSpacing = 5.67 // 0.2cm
        }

        let font = UIFont.systemFont(ofSize: fontSize)
        let numberFont = UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: .regular)

        return PDFStyle(
            fontSize: fontSize,
            lineSpacing: lineSpacing,
            font: font,
            numberFont: numberFont
        )
    }
}
