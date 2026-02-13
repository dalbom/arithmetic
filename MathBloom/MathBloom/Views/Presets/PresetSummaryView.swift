import SwiftUI

struct PresetSummaryView: View {
    let preset: Preset
    let onGenerate: (WorksheetConfig) -> Void
    let onEdit: (WorksheetConfig) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var pendingAction: PendingAction?

    private enum PendingAction {
        case generate(WorksheetConfig)
        case edit(WorksheetConfig)
    }

    private var config: WorksheetConfig? {
        preset.worksheetConfig
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    headerSection

                    if let config {
                        // Operation cards
                        if !config.problems.isEmpty {
                            operationCardsSection(config.problems)
                        }

                        // Page settings
                        pageSettingsCard(config)

                        // Options
                        optionsCard(config)
                    }

                    // Action buttons
                    actionButtons
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("preset_summary_title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("done") { dismiss() }
                }
            }
        }
        .onDisappear {
            if let action = pendingAction {
                switch action {
                case .generate(let config):
                    onGenerate(config)
                case .edit(let config):
                    onEdit(config)
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(Color(hex: preset.iconColorHex) ?? .blue)
                .frame(width: 56, height: 56)
                .overlay {
                    Image(systemName: "doc.text")
                        .font(.title2)
                        .foregroundStyle(.white)
                }

            Text(preset.name)
                .font(.title2.bold())

            if !preset.childName.isEmpty {
                Text(preset.childName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text(preset.lastUsedAt, style: .date)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Operation Cards

    private func operationCardsSection(_ problems: [ProblemConfig]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("preset_summary_operations")
                .font(.headline)
                .padding(.horizontal, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(problems) { problem in
                        operationCard(problem)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }

    private func operationCard(_ problem: ProblemConfig) -> some View {
        let color = operationColor(problem.type)
        return VStack(spacing: 8) {
            Text(problem.type.symbol)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(color)

            Text(problem.type.localizedName)
                .font(.caption.bold())

            Divider()

            digitsSummary(problem)
                .font(.caption2)
                .foregroundStyle(.secondary)

            Text("preset_summary_questions \(problem.questionsPerPage)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(width: 120)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Page Settings

    private func pageSettingsCard(_ config: WorksheetConfig) -> some View {
        ColorfulCardView(accentColor: .blue) {
            VStack(alignment: .leading, spacing: 6) {
                Text("preset_summary_page_settings")
                    .font(.headline)

                HStack {
                    Label("preset_summary_pages \(config.numberOfPages)", systemImage: "doc.on.doc")
                        .font(.subheadline)
                    Spacer()
                    if config.includeAnswerKey {
                        Label("include_answer_key", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
            }
        }
    }

    // MARK: - Options

    private func optionsCard(_ config: WorksheetConfig) -> some View {
        let hasOptions = config.problems.contains { $0.easyMode || $0.carryControl != .none } ||
            !config.childName.isEmpty || !config.schoolName.isEmpty

        return Group {
            if hasOptions {
                ColorfulCardView(accentColor: .purple) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("preset_summary_options")
                            .font(.headline)

                        if !config.childName.isEmpty {
                            Label(config.childName, systemImage: "person")
                                .font(.subheadline)
                        }
                        if !config.schoolName.isEmpty {
                            Label(config.schoolName, systemImage: "building.2")
                                .font(.subheadline)
                        }

                        ForEach(config.problems) { problem in
                            if problem.easyMode {
                                Label {
                                    HStack(spacing: 4) {
                                        Text(problem.type.symbol)
                                        Text("easy_mode_label")
                                    }
                                } icon: {
                                    Image(systemName: "star")
                                }
                                .font(.caption)
                                .foregroundStyle(.orange)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 10) {
            ChildFriendlyButton("preset_summary_generate", systemImage: "doc.badge.plus", color: .blue) {
                guard let config else { return }
                pendingAction = .generate(config)
                dismiss()
            }

            ChildFriendlyButton("preset_summary_edit", systemImage: "pencil", color: .gray) {
                guard let config else { return }
                pendingAction = .edit(config)
                dismiss()
            }
        }
        .padding(.top, 8)
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
