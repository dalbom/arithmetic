import Foundation

final class LaTeXGenerator {

    /// Generate LaTeX content for a worksheet (port of Python generate_latex())
    static func generateLaTeX(from worksheet: GeneratedWorksheet, showBranding: Bool = true) -> String {
        let config = worksheet.config
        let totalQuestions = config.totalQuestionsPerPage

        // LaTeX document header (matching Python template)
        var latex = """
        \\documentclass[12pt,a4paper]{article}
        \\usepackage[utf8]{inputenc}
        \\usepackage[margin=2cm]{geometry}
        \\usepackage{multicol}
        \\usepackage{fancyhdr}
        \\usepackage{xcolor}
        \\usepackage{CJKutf8}

        \\pagestyle{fancy}
        \\fancyhf{}
        \\renewcommand{\\headrulewidth}{0pt}
        \\renewcommand{\\footrulewidth}{0pt}
        \\cfoot{\\thepage}

        \\setlength{\\parindent}{0pt}
        \\setlength{\\columnsep}{2cm}

        \\begin{document}
        \\begin{CJK}{UTF8}{mj}

        """

        // Set starting page number
        latex += "\\setcounter{page}{\(config.pageOffset)}\n\n"

        // Determine font size and spacing (matching Python logic)
        let fontSize: String
        let vSpace: String

        if totalQuestions <= 20 {
            fontSize = "\\Large"
            vSpace = "0.8cm"
        } else if totalQuestions <= 30 {
            fontSize = "\\large"
            vSpace = "0.5cm"
        } else if totalQuestions <= 40 {
            fontSize = "\\normalsize"
            vSpace = "0.3cm"
        } else {
            fontSize = "\\small"
            vSpace = "0.2cm"
        }

        // Generate pages
        for (pageIndex, page) in worksheet.pages.enumerated() {
            // Custom header if present
            if !config.childName.isEmpty || !config.schoolName.isEmpty {
                let headerParts = [config.childName, config.schoolName].filter { !$0.isEmpty }
                latex += "\\noindent \\textbf{\(headerParts.joined(separator: " \\hfill "))}\n\n"
                latex += "\\vspace{0.2cm}\n\n"
            }

            // Date field (localized)
            let locale = Locale(identifier: UserDefaults.standard.string(forKey: "appLanguage") ?? "ko")
            let dateLabel = String(localized: "date_label", locale: locale)
            latex += "\\noindent \(dateLabel) \\underline{\\hspace{5cm}}\n\n"
            latex += "\\vspace{0.5cm}\n\n"

            // Start 2-column layout
            latex += "\\begin{multicols}{2}\n"
            latex += "\(fontSize)\n\n"

            // Pre-calculate alignment widths for this page
            let maxNumDigits = page.problems.map { String($0.problemNumber).count }.max() ?? 1
            let maxOperandCount = page.problems.map { $0.operands.count }.max() ?? 2
            var maxOpDigits = [Int](repeating: 0, count: maxOperandCount)
            for p in page.problems {
                for (i, op) in p.operands.enumerated() {
                    maxOpDigits[i] = max(maxOpDigits[i], String(abs(op)).count)
                }
            }

            // Generate problems with aligned columns
            for problem in page.problems {
                let numWidth = CGFloat(maxNumDigits) * 0.6 // em per digit
                latex += "\\noindent \\makebox[\(String(format: "%.1f", numWidth))em][r]{\(problem.problemNumber)}. "
                for (i, operand) in problem.operands.enumerated() {
                    if i > 0 {
                        let opStr = latexOperatorString(problem.operation)
                        latex += " \(opStr) "
                    }
                    let fieldWidth = CGFloat(maxOpDigits[i]) * 0.6
                    latex += "\\makebox[\(String(format: "%.1f", fieldWidth))em][r]{\(operand)}"
                }
                latex += " $=$ \\underline{\\hspace{3cm}}\n\n"
                latex += "\\vspace{\(vSpace)}\n\n"
            }

            // End 2-column layout
            latex += "\\end{multicols}\n\n"

            // Branding footer for free tier
            if showBranding {
                let brandingText = String(localized: "pdf_branding", locale: locale)
                latex += "\\vfill\n"
                latex += "\\begin{center}\n"
                latex += "\\footnotesize\\textcolor{gray}{\(brandingText)}\n"
                latex += "\\end{center}\n\n"
            }

            // Page break if not last page
            if pageIndex < worksheet.pages.count - 1 {
                latex += "\\newpage\n\n"
            }
        }

        // Document footer
        latex += """

        \\end{CJK}
        \\end{document}
        """

        return latex
    }

    /// Get LaTeX operator string for an operation type
    private static func latexOperatorString(_ operation: OperationType) -> String {
        switch operation {
        case .addition: return "$+$"
        case .subtraction: return "$-$"
        case .multiplication: return "$\\times$"
        case .division: return "$\\div$"
        }
    }

    /// Generate LaTeX for answer key
    static func generateAnswerKeyLaTeX(from worksheet: GeneratedWorksheet, showBranding: Bool = true) -> String {
        let config = worksheet.config
        let totalQuestions = config.totalQuestionsPerPage

        var latex = """
        \\documentclass[12pt,a4paper]{article}
        \\usepackage[utf8]{inputenc}
        \\usepackage[margin=2cm]{geometry}
        \\usepackage{multicol}
        \\usepackage{fancyhdr}
        \\usepackage{xcolor}
        \\usepackage{CJKutf8}

        \\pagestyle{fancy}
        \\fancyhf{}
        \\renewcommand{\\headrulewidth}{0pt}
        \\renewcommand{\\footrulewidth}{0pt}
        \\cfoot{\\thepage}

        \\setlength{\\parindent}{0pt}
        \\setlength{\\columnsep}{2cm}

        \\begin{document}
        \\begin{CJK}{UTF8}{mj}

        """

        latex += "\\setcounter{page}{\(config.pageOffset)}\n\n"

        let locale = Locale(identifier: UserDefaults.standard.string(forKey: "appLanguage") ?? "ko")
        let answerKeyTitle = String(localized: "answer_key_title", locale: locale)

        let fontSize: String
        let vSpace: String
        if totalQuestions <= 20 { fontSize = "\\Large"; vSpace = "0.8cm" }
        else if totalQuestions <= 30 { fontSize = "\\large"; vSpace = "0.5cm" }
        else if totalQuestions <= 40 { fontSize = "\\normalsize"; vSpace = "0.3cm" }
        else { fontSize = "\\small"; vSpace = "0.2cm" }

        for (pageIndex, page) in worksheet.pages.enumerated() {
            latex += "\\noindent \\textbf{\(answerKeyTitle)}\n\n"
            latex += "\\vspace{0.5cm}\n\n"
            latex += "\\begin{multicols}{2}\n"
            latex += "\(fontSize)\n\n"

            // Pre-calculate alignment widths for this page
            let maxNumDigits = page.problems.map { String($0.problemNumber).count }.max() ?? 1
            let maxOperandCount = page.problems.map { $0.operands.count }.max() ?? 2
            var maxOpDigits = [Int](repeating: 0, count: maxOperandCount)
            for p in page.problems {
                for (i, op) in p.operands.enumerated() {
                    maxOpDigits[i] = max(maxOpDigits[i], String(abs(op)).count)
                }
            }

            for problem in page.problems {
                let numWidth = CGFloat(maxNumDigits) * 0.6
                latex += "\\noindent \\makebox[\(String(format: "%.1f", numWidth))em][r]{\(problem.problemNumber)}. "
                for (i, operand) in problem.operands.enumerated() {
                    if i > 0 {
                        let opStr = latexOperatorString(problem.operation)
                        latex += " \(opStr) "
                    }
                    let fieldWidth = CGFloat(maxOpDigits[i]) * 0.6
                    latex += "\\makebox[\(String(format: "%.1f", fieldWidth))em][r]{\(operand)}"
                }
                latex += " $=$ \\textbf{\(problem.answer)}\n\n"
                latex += "\\vspace{\(vSpace)}\n\n"
            }

            latex += "\\end{multicols}\n\n"

            // Branding footer for free tier
            if showBranding {
                let brandingText = String(localized: "pdf_branding", locale: locale)
                latex += "\\vfill\n"
                latex += "\\begin{center}\n"
                latex += "\\footnotesize\\textcolor{gray}{\(brandingText)}\n"
                latex += "\\end{center}\n\n"
            }

            if pageIndex < worksheet.pages.count - 1 {
                latex += "\\newpage\n\n"
            }
        }

        latex += """

        \\end{CJK}
        \\end{document}
        """

        return latex
    }
}
