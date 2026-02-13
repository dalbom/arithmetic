import SwiftUI

struct RecordsView: View {
    @State private var selectedSegment: RecordSegment = .worksheets

    var onEditPreset: ((WorksheetConfig) -> Void)?
    var onGenerateFromPreset: ((WorksheetConfig) -> Void)?

    enum RecordSegment: String, CaseIterable {
        case worksheets
        case presets

        var localizedTitle: LocalizedStringKey {
            switch self {
            case .worksheets: return "records_worksheets"
            case .presets: return "records_presets"
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("records_tab", selection: $selectedSegment) {
                    ForEach(RecordSegment.allCases, id: \.self) { segment in
                        Text(segment.localizedTitle).tag(segment)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                Group {
                    switch selectedSegment {
                    case .worksheets:
                        WorksheetHistoryListView()
                    case .presets:
                        PresetListView(
                            onEditPreset: onEditPreset,
                            onGenerateFromPreset: onGenerateFromPreset
                        )
                    }
                }
                .frame(maxHeight: .infinity)
            }
            .navigationTitle("records_tab")
        }
    }
}
