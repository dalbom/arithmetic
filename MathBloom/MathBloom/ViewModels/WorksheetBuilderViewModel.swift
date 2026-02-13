import SwiftUI

@Observable
final class WorksheetBuilderViewModel {
    var config = WorksheetConfig()
    var generatedWorksheet: GeneratedWorksheet?
    var isGenerating = false
    var validationErrors: [LocalizedStringKey] = []
    var useLatexPDF = false  // Pro feature: use TeXLive.net

    func addProblemType() {
        config.problems.append(ProblemConfig())
    }

    func removeProblemType(at index: Int) {
        guard config.problems.count > 1, config.problems.indices.contains(index) else { return }
        config.problems.remove(at: index)
    }

    func validate() -> Bool {
        validationErrors = config.validate()
        return validationErrors.isEmpty
    }

    func generate() {
        guard validate() else { return }

        isGenerating = true
        generatedWorksheet = nil

        Task.detached { [config, useLatexPDF] in
            // Generate problems
            var worksheet = ArithmeticEngine.generateWorksheet(config: config)

            let storeManager = StoreManager.shared
            let showBranding = !storeManager.isProUnlocked

            // Render PDF
            if useLatexPDF && storeManager.isProUnlocked {
                // Try LaTeX PDF via TeXLive.net
                do {
                    let latex = LaTeXGenerator.generateLaTeX(from: worksheet, showBranding: showBranding)
                    let client = TeXLiveAPIClient()
                    let pdfData = try await client.compileToPDF(texContent: latex)
                    worksheet.worksheetPDFData = pdfData

                    if config.includeAnswerKey {
                        let answerLatex = LaTeXGenerator.generateAnswerKeyLaTeX(from: worksheet, showBranding: showBranding)
                        let answerPDF = try await client.compileToPDF(texContent: answerLatex)
                        worksheet.answerKeyPDFData = answerPDF
                    }
                } catch {
                    // Fallback to native renderer
                    worksheet.worksheetPDFData = NativePDFRenderer.render(worksheet: worksheet, showBranding: showBranding)
                    if config.includeAnswerKey {
                        worksheet.answerKeyPDFData = NativePDFRenderer.render(worksheet: worksheet, isAnswerKey: true, showBranding: showBranding)
                    }
                }
            } else {
                // Native PDF rendering
                worksheet.worksheetPDFData = NativePDFRenderer.render(worksheet: worksheet, showBranding: showBranding)
                if config.includeAnswerKey {
                    worksheet.answerKeyPDFData = NativePDFRenderer.render(worksheet: worksheet, isAnswerKey: true, showBranding: showBranding)
                }
            }

            let finalWorksheet = worksheet
            await MainActor.run {
                self.generatedWorksheet = finalWorksheet
                self.isGenerating = false
            }
        }
    }

    /// Flag set when a preset is loaded, so WizardView can jump to review step
    var presetJustLoaded = false

    /// Load a config from a preset
    func loadConfig(_ newConfig: WorksheetConfig) {
        config = newConfig
        generatedWorksheet = nil
        validationErrors = []
        presetJustLoaded = true
    }
}
