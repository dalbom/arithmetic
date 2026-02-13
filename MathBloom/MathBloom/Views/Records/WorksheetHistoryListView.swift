import SwiftUI
import SwiftData

struct WorksheetHistoryListView: View {
    @Query(sort: \WorksheetRecord.createdAt, order: .reverse) private var records: [WorksheetRecord]
    @Environment(\.modelContext) private var modelContext
    @State private var selectedRecord: WorksheetRecord?

    var body: some View {
        Group {
            if records.isEmpty {
                ContentUnavailableView(
                    "no_worksheets_title",
                    systemImage: "doc.text",
                    description: Text("no_worksheets_description")
                )
            } else {
                List {
                    ForEach(records) { record in
                        WorksheetRecordRowView(record: record)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedRecord = record
                            }
                    }
                    .onDelete(perform: deleteRecords)
                }
            }
        }
        .fullScreenCover(item: $selectedRecord) { record in
            if let pdfData = record.worksheetPDFData {
                PDFPreviewView(viewModel: PDFPreviewViewModel(
                    worksheet: GeneratedWorksheet(
                        pages: [],
                        config: record.worksheetConfig ?? WorksheetConfig(),
                        worksheetPDFData: pdfData,
                        answerKeyPDFData: record.answerKeyPDFData
                    )
                ))
            }
        }
    }

    private func deleteRecords(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(records[index])
        }
    }
}

// MARK: - Row View

private struct WorksheetRecordRowView: View {
    let record: WorksheetRecord

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.blue.gradient)
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: "doc.text.fill")
                        .foregroundStyle(.white)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(record.displayTitle)
                    .font(.subheadline.bold())

                if let config = record.worksheetConfig {
                    HStack(spacing: 4) {
                        ForEach(Array(config.problems.enumerated()), id: \.offset) { idx, pc in
                            if idx > 0 {
                                Text(",")
                            }
                            digitsSummary(pc)
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }

    private func digitsSummary(_ pc: ProblemConfig) -> Text {
        var result = Text("n_digit \(pc.operandDigits[0])")
        for i in 1..<pc.operandDigits.count {
            result = result + Text(" \(pc.type.symbol) ") + Text("n_digit \(pc.operandDigits[i])")
        }
        return result
    }
}
