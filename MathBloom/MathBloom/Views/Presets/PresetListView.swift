import SwiftUI
import SwiftData

struct PresetListView: View {
    @Query(sort: \Preset.lastUsedAt, order: .reverse) private var presets: [Preset]
    @Environment(\.modelContext) private var modelContext
    @State private var showPaywall = false
    @State private var selectedPreset: Preset?
    let storeManager = StoreManager.shared

    /// Callback when user taps "Edit" in summary
    var onEditPreset: ((WorksheetConfig) -> Void)?
    /// Callback when user taps "Generate" in summary
    var onGenerateFromPreset: ((WorksheetConfig) -> Void)?

    var body: some View {
        Group {
            if presets.isEmpty {
                ContentUnavailableView(
                    "no_presets_title",
                    systemImage: "bookmark",
                    description: Text("no_presets_description")
                )
            } else {
                List {
                    ForEach(presets) { preset in
                        PresetRowView(preset: preset)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedPreset = preset
                            }
                    }
                    .onDelete(perform: deletePresets)
                }
            }
        }
        .sheet(item: $selectedPreset) { preset in
            PresetSummaryView(
                preset: preset,
                onGenerate: { config in
                    preset.lastUsedAt = Date()
                    onGenerateFromPreset?(config)
                },
                onEdit: { config in
                    preset.lastUsedAt = Date()
                    onEditPreset?(config)
                }
            )
        }
    }

    private func deletePresets(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(presets[index])
        }
    }
}

// MARK: - Preset Row

private struct PresetRowView: View {
    let preset: Preset

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: preset.iconColorHex) ?? .blue)
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: "doc.text")
                        .foregroundStyle(.white)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(preset.name)
                    .font(.headline)

                if !preset.childName.isEmpty {
                    Text(preset.childName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(preset.lastUsedAt, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Color Extension for Hex

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        guard hexSanitized.count == 6,
              let hexInt = UInt64(hexSanitized, radix: 16) else { return nil }

        let r = Double((hexInt >> 16) & 0xFF) / 255.0
        let g = Double((hexInt >> 8) & 0xFF) / 255.0
        let b = Double(hexInt & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
