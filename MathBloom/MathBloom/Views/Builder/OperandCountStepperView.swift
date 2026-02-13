import SwiftUI

struct OperandCountStepperView: View {
    @Binding var config: ProblemConfig
    let storeManager = StoreManager.shared
    @State private var showPaywall = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("operand_count_label")
                    .font(.subheadline)
                Spacer()
            }

            HStack {
                Stepper(
                    "\(config.operandCount)",
                    value: Binding(
                        get: { config.operandCount },
                        set: { newValue in
                            if newValue > 2 && !storeManager.isProUnlocked {
                                showPaywall = true
                                return
                            }
                            if newValue > config.operandCount {
                                config.addOperand()
                            } else if newValue < config.operandCount {
                                config.removeLastOperand()
                            }
                        }
                    ),
                    in: 2...5
                )
                .font(.subheadline.monospacedDigit())
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(triggeredFeature: .multipleOperands)
        }
    }
}
