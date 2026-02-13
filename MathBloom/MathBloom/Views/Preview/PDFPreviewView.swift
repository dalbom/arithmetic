import SwiftUI
import PDFKit

struct PDFPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: PDFPreviewViewModel
    @State private var showShareSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Answer key toggle if available
                if viewModel.answerKeyPDFData != nil {
                    Picker("preview_mode", selection: $viewModel.showingAnswerKey) {
                        Text("worksheet_tab").tag(false)
                        Text("answer_key_tab").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                }

                // PDF view
                if let pdfData = viewModel.currentPDFData {
                    PDFKitView(data: pdfData)
                } else {
                    ContentUnavailableView(
                        "no_pdf_title",
                        systemImage: "doc.questionmark",
                        description: Text("no_pdf_description")
                    )
                }
            }
            .navigationTitle("preview_title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("done") { dismiss() }
                }

                ToolbarItemGroup(placement: .primaryAction) {
                    // Share
                    if let data = viewModel.currentPDFData {
                        ShareLink(
                            item: PDFDataItem(data: data, filename: viewModel.filename),
                            preview: SharePreview(viewModel.filename)
                        )
                    }

                    // Print
                    Button {
                        if let data = viewModel.currentPDFData {
                            PrintManager.printPDF(data, jobName: viewModel.filename)
                        }
                    } label: {
                        Image(systemName: "printer")
                    }
                }
            }
        }
    }
}

// MARK: - PDFKit UIViewRepresentable

struct PDFKitView: UIViewRepresentable {
    let data: Data

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        return pdfView
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {
        if let document = PDFDocument(data: data) {
            pdfView.document = document
        }
    }
}

// MARK: - Transferable for ShareLink

struct PDFDataItem: Transferable {
    let data: Data
    let filename: String

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .pdf) { item in
            item.data
        }
    }
}
