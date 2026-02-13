import Foundation

struct GeneratedPage: Identifiable {
    let id = UUID()
    let pageNumber: Int
    let problems: [GeneratedProblem]
}

struct GeneratedWorksheet {
    let pages: [GeneratedPage]
    let config: WorksheetConfig
    var worksheetPDFData: Data?
    var answerKeyPDFData: Data?
}
