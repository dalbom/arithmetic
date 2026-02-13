import SwiftUI

struct PresetDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var preset: Preset

    let colorOptions = ["#4CAF50", "#2196F3", "#FF9800", "#E91E63", "#9C27B0", "#00BCD4"]

    var body: some View {
        NavigationStack {
            Form {
                Section("preset_name_section") {
                    TextField("preset_name_label", text: $preset.name)
                }

                Section("preset_color_section") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(colorOptions, id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex) ?? .blue)
                                .frame(width: 36, height: 36)
                                .overlay {
                                    if preset.iconColorHex == hex {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.white)
                                            .font(.caption.bold())
                                    }
                                }
                                .onTapGesture {
                                    preset.iconColorHex = hex
                                }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("preset_info_section") {
                    LabeledContent("preset_created") {
                        Text(preset.createdAt, style: .date)
                    }
                    LabeledContent("preset_last_used") {
                        Text(preset.lastUsedAt, style: .date)
                    }
                }
            }
            .navigationTitle("edit_preset_title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("done") { dismiss() }
                }
            }
        }
    }
}
