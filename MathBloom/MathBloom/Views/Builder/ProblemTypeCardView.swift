import SwiftUI

struct ProblemTypeCardView: View {
    @Binding var config: ProblemConfig
    let index: Int
    let onDelete: () -> Void
    let storeManager = StoreManager.shared
    @State private var paywallFeature: ProFeature?

    private var accentColor: Color {
        switch config.type {
        case .addition: return .green
        case .subtraction: return .pink
        case .multiplication: return .blue
        case .division: return .orange
        }
    }

    var body: some View {
        ColorfulCardView(accentColor: accentColor) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with type and delete
                HStack {
                    Text("problem_type_header \(index + 1)")
                        .font(.headline)
                    Spacer()
                    Button(role: .destructive, action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                }

                // Operation type picker
                OperationPickerView(selectedType: $config.type)

                Divider()

                // Operand digit controls
                ForEach(config.operandDigits.indices, id: \.self) { i in
                    let maxDigits = storeManager.maxDigits
                    DigitSliderView(
                        "operand_digits_label \(i + 1)",
                        value: Binding(
                            get: { config.operandDigits[i] },
                            set: { newVal in
                                if newVal > 2 && !storeManager.isProUnlocked {
                                    paywallFeature = .extendedDigits
                                    return
                                }
                                config.operandDigits[i] = newVal
                            }
                        ),
                        range: 1...maxDigits
                    )
                }

                // Operand count stepper (Pro)
                OperandCountStepperView(config: $config)

                Divider()

                // Questions per page
                HStack {
                    Text("questions_per_page_label")
                        .font(.subheadline)
                    Spacer()
                    Stepper(
                        "\(config.questionsPerPage)",
                        value: $config.questionsPerPage,
                        in: 1...50
                    )
                    .font(.subheadline.monospacedDigit())
                }

                // Easy mode toggle
                EasyModeToggleView(isEnabled: $config.easyMode, operationType: config.type)

                // Carry/borrow control
                CarryBorrowToggleView(carryControl: $config.carryControl, operationType: config.type, paywallFeature: $paywallFeature)
            }
        }
        .sheet(item: $paywallFeature) { feature in
            PaywallView(triggeredFeature: feature)
        }
    }
}
