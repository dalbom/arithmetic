import SwiftUI

struct WizardStepOptionsView: View {
    @Binding var config: ProblemConfig
    @Binding var paywallFeature: ProFeature?
    let storeManager = StoreManager.shared

    var body: some View {
        Form {
            Text("wizard_options_prompt")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))

            Section {
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

                // Quick adjustment buttons
                HStack(spacing: 8) {
                    ForEach([-10, -5, 5, 10], id: \.self) { delta in
                        Button {
                            let newValue = config.questionsPerPage + delta
                            config.questionsPerPage = max(1, min(50, newValue))
                        } label: {
                            Text(delta > 0 ? "+\(delta)" : "\(delta)")
                                .font(.subheadline.weight(.medium).monospacedDigit())
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray5))
                                .foregroundStyle(.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            if config.type.supportsEasyMode {
                Section {
                    EasyModeToggleView(isEnabled: $config.easyMode, operationType: config.type)
                }
            }

            if config.type.supportsCarryControl {
                Section {
                    CarryBorrowToggleView(carryControl: $config.carryControl, operationType: config.type, paywallFeature: $paywallFeature)
                }
            }
        }
    }
}
