import SwiftUI

struct WizardStepOperationView: View {
    @Binding var config: ProblemConfig
    @Binding var paywallFeature: ProFeature?
    let storeManager = StoreManager.shared

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("wizard_operation_prompt")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(OperationType.allCases) { op in
                        OperationCardButton(
                            operation: op,
                            isSelected: config.type == op
                        ) {
                            selectOperation(op)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }

    private func selectOperation(_ op: OperationType) {
        if op.requiresPro && !storeManager.isProUnlocked {
            paywallFeature = op == .multiplication ? .multiplication : .division
            return
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            config.type = op
        }
    }
}

// MARK: - Operation Card

private struct OperationCardButton: View {
    let operation: OperationType
    let isSelected: Bool
    let action: () -> Void

    private var color: Color {
        switch operation {
        case .addition: return .green
        case .subtraction: return .pink
        case .multiplication: return .blue
        case .division: return .orange
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Text(operation.symbol)
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(isSelected ? .white : color)

                Text(operation.localizedName)
                    .font(.subheadline.bold())
                    .foregroundStyle(isSelected ? .white : .primary)

                if operation.requiresPro {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                        .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? color : color.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? color : color.opacity(0.2), lineWidth: isSelected ? 3 : 1)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
    }
}
