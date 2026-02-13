import SwiftUI

struct WizardStepIndicatorView: View {
    let currentStep: WizardStep
    let steps = WizardStep.allCases

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(steps.enumerated()), id: \.element) { index, step in
                if index > 0 {
                    // Connecting line
                    Rectangle()
                        .fill(step.rawValue <= currentStep.rawValue ? Color.blue : Color.gray.opacity(0.3))
                        .frame(height: 2)
                }

                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(circleColor(for: step))
                            .frame(width: step == currentStep ? 34 : 30, height: step == currentStep ? 34 : 30)

                        if step.rawValue < currentStep.rawValue {
                            // Completed: checkmark
                            Image(systemName: "checkmark")
                                .font(.caption.bold())
                                .foregroundStyle(.white)
                        } else {
                            // Current or future: number
                            Text("\(step.rawValue + 1)")
                                .font(.caption.bold())
                                .foregroundStyle(step.rawValue <= currentStep.rawValue ? .white : .gray)
                        }
                    }
                    .animation(.spring(response: 0.3), value: currentStep)

                    Text(step.shortTitleKey)
                        .font(.system(size: 10))
                        .foregroundStyle(step == currentStep ? .primary : .secondary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private func circleColor(for step: WizardStep) -> Color {
        if step.rawValue < currentStep.rawValue {
            return .blue
        } else if step == currentStep {
            return .blue
        } else {
            return .gray.opacity(0.3)
        }
    }
}
