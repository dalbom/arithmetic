import SwiftUI

@Observable
final class PDFPreviewViewModel {
    let worksheetPDFData: Data?
    let answerKeyPDFData: Data?
    var showingAnswerKey = false
    let worksheetName: String

    init(worksheet: GeneratedWorksheet) {
        self.worksheetPDFData = worksheet.worksheetPDFData
        self.answerKeyPDFData = worksheet.answerKeyPDFData
        self.worksheetName = worksheet.config.name.isEmpty ? "worksheet" : worksheet.config.name
    }

    /// Currently displayed PDF data
    var currentPDFData: Data? {
        showingAnswerKey ? answerKeyPDFData : worksheetPDFData
    }

    /// Filename for sharing/saving
    var filename: String {
        let suffix = showingAnswerKey ? "_answers" : ""
        return "\(worksheetName)\(suffix).pdf"
    }
}
