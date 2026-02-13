import SwiftUI

struct EasyModeToggleView: View {
    @Binding var isEnabled: Bool
    let operationType: OperationType

    var body: some View {
        if operationType.supportsEasyMode {
            Toggle(isOn: $isEnabled) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("easy_mode_label")
                        .font(.subheadline)
                    Text("easy_mode_description")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .tint(.green)
        }
    }
}
