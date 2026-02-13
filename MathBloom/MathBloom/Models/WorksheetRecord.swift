import Foundation
import SwiftData

@Model
final class WorksheetRecord {
    var configData: Data
    var worksheetPDFData: Data?
    var answerKeyPDFData: Data?
    var createdAt: Date
    var sequenceNumber: Int = 1

    init(config: WorksheetConfig, worksheetPDF: Data?, answerKeyPDF: Data?, sequenceNumber: Int = 1) {
        self.configData = (try? JSONEncoder().encode(config)) ?? Data()
        self.worksheetPDFData = worksheetPDF
        self.answerKeyPDFData = answerKeyPDF
        self.createdAt = Date()
        self.sequenceNumber = sequenceNumber
    }

    /// Decode the stored config
    var worksheetConfig: WorksheetConfig? {
        try? JSONDecoder().decode(WorksheetConfig.self, from: configData)
    }

    /// Localized title: "2026년 2월 13일 문제지 #1"
    var displayTitle: String {
        let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "ko"
        let locale = Locale(identifier: lang)
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        let dateStr = formatter.string(from: createdAt)
        let label = String(localized: "worksheet_title_format", locale: locale)
        return String(format: label, dateStr, sequenceNumber)
    }
}
