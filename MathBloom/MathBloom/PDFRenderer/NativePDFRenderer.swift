import UIKit

final class NativePDFRenderer {

    /// Render a worksheet to PDF data
    static func render(worksheet: GeneratedWorksheet, isAnswerKey: Bool = false, showBranding: Bool = true) -> Data {
        let format = UIGraphicsPDFRendererFormat()
        let renderer = UIGraphicsPDFRenderer(bounds: PDFLayoutConstants.pageRect, format: format)

        let style = PDFStyle.forQuestionCount(worksheet.config.totalQuestionsPerPage)

        let data = renderer.pdfData { context in
            for page in worksheet.pages {
                context.beginPage()
                let cgContext = context.cgContext

                // Draw header
                drawHeader(in: cgContext, config: worksheet.config, style: style)

                // Draw problems in 2-column layout
                drawProblems(in: cgContext, problems: page.problems, style: style, isAnswerKey: isAnswerKey)

                // Draw footer
                drawFooter(in: cgContext, pageNumber: page.pageNumber, showBranding: showBranding)
            }
        }

        return data
    }

    // MARK: - Header

    private static func drawHeader(in context: CGContext, config: WorksheetConfig, style: PDFStyle) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left

        var yPos = PDFLayoutConstants.dateFieldY

        // Child name + school name (Pro feature - only shown if not empty)
        if !config.childName.isEmpty || !config.schoolName.isEmpty {
            let headerText = [config.childName, config.schoolName]
                .filter { !$0.isEmpty }
                .joined(separator: "  |  ")

            let headerAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: style.fontSize, weight: .medium),
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle,
            ]

            let headerRect = CGRect(
                x: PDFLayoutConstants.marginLeft,
                y: yPos,
                width: PDFLayoutConstants.contentWidth,
                height: 20
            )
            (headerText as NSString).draw(in: headerRect, withAttributes: headerAttrs)
            yPos += 22
        }

        // Date field: "날짜: __________" (or "Date: __________")
        let locale = Locale(identifier: UserDefaults.standard.string(forKey: "appLanguage") ?? "ko")
        let dateLabel = String(localized: "date_label", locale: locale)
        let dateAttrs: [NSAttributedString.Key: Any] = [
            .font: style.font,
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraphStyle,
        ]

        let dateLabelSize = (dateLabel as NSString).size(withAttributes: dateAttrs)
        let dateRect = CGRect(
            x: PDFLayoutConstants.marginLeft,
            y: yPos,
            width: dateLabelSize.width + 10,
            height: dateLabelSize.height
        )
        (dateLabel as NSString).draw(in: dateRect, withAttributes: dateAttrs)

        // Draw underline for date
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(0.5)
        let underlineStartX = PDFLayoutConstants.marginLeft + dateLabelSize.width + 5
        let underlineY = yPos + dateLabelSize.height - 2
        context.move(to: CGPoint(x: underlineStartX, y: underlineY))
        context.addLine(to: CGPoint(x: underlineStartX + PDFLayoutConstants.dateUnderlineWidth, y: underlineY))
        context.strokePath()
    }

    // MARK: - Problems

    private static func drawProblems(in context: CGContext, problems: [GeneratedProblem], style: PDFStyle, isAnswerKey: Bool) {
        let totalProblems = problems.count
        let halfCount = (totalProblems + 1) / 2

        let leftColumnX = PDFLayoutConstants.marginLeft
        let rightColumnX = PDFLayoutConstants.marginLeft + PDFLayoutConstants.columnWidth + PDFLayoutConstants.columnGap

        let problemHeight = style.fontSize + style.lineSpacing
        let yPos = PDFLayoutConstants.problemAreaTop

        let attrs: [NSAttributedString.Key: Any] = [
            .font: style.numberFont,
            .foregroundColor: UIColor.black,
        ]

        // Pre-calculate alignment metrics
        let digitWidth = ("0" as NSString).size(withAttributes: attrs).width
        let dotSpaceStr = ". "
        let dotSpaceWidth = (dotSpaceStr as NSString).size(withAttributes: attrs).width
        let equalsStr = " = "
        let equalsWidth = (equalsStr as NSString).size(withAttributes: attrs).width
        let answerLineWidth: CGFloat = 85.0

        // Max problem number digit count
        let maxNumDigits = problems.map { String($0.problemNumber).count }.max() ?? 1

        // Max operand count and max digits per operand position
        let maxOperandCount = problems.map { $0.operands.count }.max() ?? 2
        var maxOperandDigits = [Int](repeating: 0, count: maxOperandCount)
        for problem in problems {
            for (i, operand) in problem.operands.enumerated() {
                maxOperandDigits[i] = max(maxOperandDigits[i], String(abs(operand)).count)
            }
        }

        // Max operator width (different symbols may have different widths)
        var maxOpWidth: CGFloat = 0
        let uniqueOps = Set(problems.map { $0.operation })
        for op in uniqueOps {
            let w = (" \(op.symbol) " as NSString).size(withAttributes: attrs).width
            maxOpWidth = max(maxOpWidth, w)
        }

        for (index, problem) in problems.enumerated() {
            let isLeftColumn = index < halfCount
            let columnX = isLeftColumn ? leftColumnX : rightColumnX
            let rowIndex = isLeftColumn ? index : index - halfCount
            let currentY = yPos + CGFloat(rowIndex) * problemHeight

            var x = columnX

            // 1. Problem number (right-aligned in fixed field)
            let numStr = "\(problem.problemNumber)"
            let numFieldWidth = CGFloat(maxNumDigits) * digitWidth
            let numTextWidth = (numStr as NSString).size(withAttributes: attrs).width
            (numStr as NSString).draw(at: CGPoint(x: x + numFieldWidth - numTextWidth, y: currentY), withAttributes: attrs)
            x += numFieldWidth

            // 2. Dot + space
            (dotSpaceStr as NSString).draw(at: CGPoint(x: x, y: currentY), withAttributes: attrs)
            x += dotSpaceWidth

            // 3. Operands with operators between them
            for (i, operand) in problem.operands.enumerated() {
                if i > 0 {
                    let opStr = " \(problem.operation.symbol) "
                    let opStrWidth = (opStr as NSString).size(withAttributes: attrs).width
                    let opPadding = (maxOpWidth - opStrWidth) / 2
                    (opStr as NSString).draw(at: CGPoint(x: x + opPadding, y: currentY), withAttributes: attrs)
                    x += maxOpWidth
                }

                let operandStr = String(operand)
                let fieldWidth = CGFloat(maxOperandDigits[i]) * digitWidth
                let operandWidth = (operandStr as NSString).size(withAttributes: attrs).width
                (operandStr as NSString).draw(at: CGPoint(x: x + fieldWidth - operandWidth, y: currentY), withAttributes: attrs)
                x += fieldWidth
            }

            // Pad remaining operand positions if this problem has fewer operands
            for i in problem.operands.count..<maxOperandCount {
                x += maxOpWidth + CGFloat(maxOperandDigits[i]) * digitWidth
            }

            // 4. Equals sign
            (equalsStr as NSString).draw(at: CGPoint(x: x, y: currentY), withAttributes: attrs)
            x += equalsWidth

            // 5. Answer or blank
            if isAnswerKey {
                let answerStr = String(problem.answer)
                (answerStr as NSString).draw(at: CGPoint(x: x, y: currentY), withAttributes: attrs)
            } else {
                let underlineY = currentY + style.fontSize
                context.setStrokeColor(UIColor.black.cgColor)
                context.setLineWidth(0.5)
                context.move(to: CGPoint(x: x, y: underlineY))
                context.addLine(to: CGPoint(x: x + answerLineWidth, y: underlineY))
                context.strokePath()
            }
        }
    }

    // MARK: - Footer

    private static func drawFooter(in context: CGContext, pageNumber: Int, showBranding: Bool) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        // Page number
        let pageNumberAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraphStyle,
        ]

        let pageText = "\(pageNumber)"
        let pageRect = CGRect(
            x: PDFLayoutConstants.marginLeft,
            y: PDFLayoutConstants.footerY,
            width: PDFLayoutConstants.contentWidth,
            height: 14
        )
        (pageText as NSString).draw(in: pageRect, withAttributes: pageNumberAttrs)

        // Branding footer for free tier
        if showBranding {
            let brandingAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 8),
                .foregroundColor: UIColor.gray,
                .paragraphStyle: paragraphStyle,
            ]

            let locale = Locale(identifier: UserDefaults.standard.string(forKey: "appLanguage") ?? "ko")
            let brandingText = String(localized: "pdf_branding", locale: locale)
            let brandingRect = CGRect(
                x: PDFLayoutConstants.marginLeft,
                y: PDFLayoutConstants.footerY + 14,
                width: PDFLayoutConstants.contentWidth,
                height: 12
            )
            (brandingText as NSString).draw(in: brandingRect, withAttributes: brandingAttrs)
        }
    }
}
