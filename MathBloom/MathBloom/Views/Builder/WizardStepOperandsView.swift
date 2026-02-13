import SwiftUI

struct WizardStepOperandsView: View {
    @Binding var config: ProblemConfig
    @Binding var paywallFeature: ProFeature?
    let storeManager = StoreManager.shared

    var body: some View {
        Form {
            Section {
                Text("wizard_operands_prompt")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section {
                OperandCountStepperView(config: $config)
            }

            Section {
                ForEach(config.operandDigits.indices, id: \.self) { i in
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
                        range: 1...8,
                        freeLimit: storeManager.isProUnlocked ? nil : 2
                    )
                }
            }
        }
    }
}
