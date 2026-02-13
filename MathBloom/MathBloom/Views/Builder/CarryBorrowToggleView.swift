import SwiftUI

struct CarryBorrowToggleView: View {
    @Binding var carryControl: ProblemConfig.CarryControl
    let operationType: OperationType
    @Binding var paywallFeature: ProFeature?
    let storeManager = StoreManager.shared

    private var descriptionKey: LocalizedStringKey {
        switch carryControl {
        case .none:
            return operationType == .addition
                ? "carry_none_desc_addition"
                : "carry_none_desc_subtraction"
        case .requireCarry:
            return operationType == .addition
                ? "carry_require_desc_addition"
                : "carry_require_desc_subtraction"
        case .preventCarry:
            return operationType == .addition
                ? "carry_prevent_desc_addition"
                : "carry_prevent_desc_subtraction"
        }
    }

    var body: some View {
        if operationType.supportsCarryControl {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("carry_control_label")
                        .font(.subheadline)
                }

                Picker("carry_control_label", selection: $carryControl) {
                    Text("carry_none").tag(ProblemConfig.CarryControl.none)
                    Text("carry_require").tag(ProblemConfig.CarryControl.requireCarry)
                    Text("carry_prevent").tag(ProblemConfig.CarryControl.preventCarry)
                }
                .pickerStyle(.segmented)
                .disabled(!storeManager.isProUnlocked)
                .overlay {
                    if !storeManager.isProUnlocked {
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                paywallFeature = .carryControl
                            }
                    }
                }

                Text(descriptionKey)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
