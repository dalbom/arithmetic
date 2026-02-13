import SwiftUI

struct WizardStepReviewView: View {
    let worksheetConfig: WorksheetConfig
    let currentProblemConfig: ProblemConfig
    let problemTypes: [ProblemConfig]

    private var allTypes: [ProblemConfig] {
        problemTypes.isEmpty ? [currentProblemConfig] : problemTypes
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("wizard_review_prompt")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)

                // Example problem
                exampleProblemCard

                // Problem types
                ForEach(Array(allTypes.enumerated()), id: \.offset) { index, pc in
                    problemTypeRow(pc, index: index)
                }

                // Page settings
                pageSettingsCard

                // Child name
                if !worksheetConfig.childName.isEmpty {
                    ColorfulCardView(accentColor: .purple) {
                        Label(worksheetConfig.childName, systemImage: "person.fill")
                            .font(.subheadline)
                    }
                }
            }
            .padding()
        }
    }

    // MARK: - Example Problem

    private var exampleProblemCard: some View {
        let color = operationColor(currentProblemConfig.type)
        let example = ArithmeticEngine.generateProblem(config: currentProblemConfig, number: 1)
        return VStack(spacing: 8) {
            Text("wizard_example_problem")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(example.displayString)
                .font(.system(.title, design: .monospaced).bold())
                .padding(.vertical, 8)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Problem Type Row

    private func problemTypeRow(_ pc: ProblemConfig, index: Int) -> some View {
        let color = operationColor(pc.type)
        return ColorfulCardView(accentColor: color) {
            HStack {
                Text(pc.type.symbol)
                    .font(.title2.bold())
                    .foregroundStyle(color)

                VStack(alignment: .leading, spacing: 2) {
                    Text(pc.type.localizedName)
                        .font(.subheadline.bold())

                    digitsSummary(pc)
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("preset_summary_questions \(pc.questionsPerPage)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Page Settings

    private var pageSettingsCard: some View {
        ColorfulCardView(accentColor: .blue) {
            HStack {
                Label("preset_summary_pages \(worksheetConfig.numberOfPages)", systemImage: "doc.on.doc")
                    .font(.subheadline)
                Spacer()
                if worksheetConfig.includeAnswerKey {
                    Label("include_answer_key", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }
        }
    }

    // MARK: - Helpers

    private func digitsSummary(_ pc: ProblemConfig) -> Text {
        var result = Text("n_digit \(pc.operandDigits[0])")
        for i in 1..<pc.operandDigits.count {
            result = result + Text(" \(pc.type.symbol) ") + Text("n_digit \(pc.operandDigits[i])")
        }
        return result
    }

    private func operationColor(_ type: OperationType) -> Color {
        switch type {
        case .addition: return .green
        case .subtraction: return .pink
        case .multiplication: return .blue
        case .division: return .orange
        }
    }
}
