import SwiftUI
import SwiftData

enum WizardStep: Int, CaseIterable {
    case operation = 0
    case operands
    case options
    case pageSettings
    case review

    var titleKey: LocalizedStringKey {
        switch self {
        case .operation: return "wizard_step_operation"
        case .operands: return "wizard_step_operands"
        case .options: return "wizard_step_options"
        case .pageSettings: return "wizard_step_page_settings"
        case .review: return "wizard_step_review"
        }
    }

    var shortTitleKey: LocalizedStringKey {
        switch self {
        case .operation: return "step_short_operation"
        case .operands: return "step_short_operands"
        case .options: return "step_short_options"
        case .pageSettings: return "step_short_pages"
        case .review: return "step_short_review"
        }
    }

    var next: WizardStep? {
        WizardStep(rawValue: rawValue + 1)
    }

    var previous: WizardStep? {
        WizardStep(rawValue: rawValue - 1)
    }

    var progress: Double {
        Double(rawValue + 1) / Double(WizardStep.allCases.count)
    }
}

struct WizardView: View {
    @Bindable var viewModel: WorksheetBuilderViewModel
    @Environment(\.modelContext) private var modelContext

    @State private var currentStep: WizardStep = .operation
    @State private var currentProblemConfig = ProblemConfig()
    @State private var paywallFeature: ProFeature?
    @State private var showSavePreset = false
    @State private var presetName = ""
    @State private var showPDFPreview = false
    @State private var isGoingBack = false
    @State private var isAnimating = false

    let storeManager = StoreManager.shared

    var body: some View {
        VStack(spacing: 0) {
            // Step indicator
            WizardStepIndicatorView(currentStep: currentStep)

            // Step content with transition
            Group {
                switch currentStep {
                case .operation:
                    WizardStepOperationView(
                        config: $currentProblemConfig,
                        paywallFeature: $paywallFeature
                    )
                case .operands:
                    WizardStepOperandsView(
                        config: $currentProblemConfig,
                        paywallFeature: $paywallFeature
                    )
                case .options:
                    WizardStepOptionsView(
                        config: $currentProblemConfig,
                        paywallFeature: $paywallFeature
                    )
                case .pageSettings:
                    WizardStepPageSettingsView(
                        worksheetConfig: $viewModel.config,
                        paywallFeature: $paywallFeature
                    )
                case .review:
                    WizardStepReviewView(
                        worksheetConfig: viewModel.config,
                        currentProblemConfig: currentProblemConfig,
                        problemTypes: viewModel.config.problems
                    )
                }
            }
            .id(currentStep)
            .transition(.asymmetric(
                insertion: .move(edge: isGoingBack ? .leading : .trailing).combined(with: .opacity),
                removal: .move(edge: isGoingBack ? .trailing : .leading).combined(with: .opacity)
            ))
            .frame(maxHeight: .infinity)

            // Navigation buttons
            navigationButtons
        }
        .navigationTitle("create_worksheet_title")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showSavePreset = true
                } label: {
                    Image(systemName: "bookmark.fill")
                }
            }
        }
        .overlay {
            if viewModel.isGenerating {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("generating_worksheet")
                            .font(.headline)
                    }
                    .padding(30)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
        .sheet(item: $paywallFeature) { feature in
            PaywallView(triggeredFeature: feature)
        }
        .sheet(isPresented: $showSavePreset) {
            NavigationStack {
                Form {
                    TextField("preset_name_label", text: $presetName)
                }
                .navigationTitle("save_preset_title")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("cancel") { showSavePreset = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("save") {
                            let name = presetName.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !name.isEmpty else { return }
                            var configToSave = viewModel.config
                            if configToSave.problems.isEmpty {
                                configToSave.problems.append(currentProblemConfig)
                            }
                            PresetListViewModel().savePreset(from: configToSave, name: name, modelContext: modelContext)
                            presetName = ""
                            showSavePreset = false
                        }
                        .disabled(presetName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .fullScreenCover(isPresented: $showPDFPreview) {
            if let worksheet = viewModel.generatedWorksheet {
                PDFPreviewView(viewModel: PDFPreviewViewModel(worksheet: worksheet))
            }
        }
        .onChange(of: viewModel.generatedWorksheet != nil) { _, hasWorksheet in
            if hasWorksheet {
                // Save worksheet record to history
                if let ws = viewModel.generatedWorksheet {
                    // Count today's existing records for sequence number
                    var todayCount = 0
                    let startOfDay = Calendar.current.startOfDay(for: Date())
                    let allDescriptor = FetchDescriptor<WorksheetRecord>(
                        sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
                    )
                    if let allRecords = try? modelContext.fetch(allDescriptor) {
                        todayCount = allRecords.filter { $0.createdAt >= startOfDay }.count
                    }

                    let record = WorksheetRecord(
                        config: ws.config,
                        worksheetPDF: ws.worksheetPDFData,
                        answerKeyPDF: ws.answerKeyPDFData,
                        sequenceNumber: todayCount + 1
                    )
                    modelContext.insert(record)
                }
                showPDFPreview = true
            }
        }
        .onChange(of: viewModel.presetJustLoaded) { _, loaded in
            if loaded {
                viewModel.presetJustLoaded = false
                if let first = viewModel.config.problems.first {
                    currentProblemConfig = first
                }
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentStep = .review
                }
            }
        }
        .background {
            TabReselectionHandler(tabIndex: 0)
        }
        .onReceive(TabReselectionPublisher.shared.reselected) { index in
            if index == 0 {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentStep = .operation
                    currentProblemConfig = ProblemConfig()
                    viewModel.config = WorksheetConfig()
                }
            }
        }
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: 12) {
            if currentStep.previous != nil {
                Button {
                    guard !isAnimating else { return }
                    isAnimating = true
                    isGoingBack = true
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep = currentStep.previous!
                    } completion: {
                        isAnimating = false
                    }
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("wizard_back")
                    }
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(.systemGray5))
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }

            if currentStep == .review {
                Button {
                    addAnotherType()
                } label: {
                    Label("wizard_add_another", systemImage: "plus.circle")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.systemGray5))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                ChildFriendlyButton("generate_button", systemImage: "doc.badge.plus", color: .blue) {
                    generateWorksheet()
                }
            } else if currentStep.next != nil {
                ChildFriendlyButton("wizard_next", systemImage: "chevron.right", color: .blue) {
                    guard !isAnimating else { return }
                    isAnimating = true
                    isGoingBack = false
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep = currentStep.next!
                    } completion: {
                        isAnimating = false
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    // MARK: - Actions

    private func addAnotherType() {
        viewModel.config.problems.append(currentProblemConfig)
        currentProblemConfig = ProblemConfig()
        withAnimation(.easeInOut(duration: 0.3)) { currentStep = .operation }
    }

    private func generateWorksheet() {
        // Ensure current config is included
        if viewModel.config.problems.isEmpty {
            viewModel.config.problems.append(currentProblemConfig)
        } else if currentStep == .review {
            let lastAdded = viewModel.config.problems.last
            if lastAdded?.type == currentProblemConfig.type &&
               lastAdded?.operandDigits == currentProblemConfig.operandDigits {
                // Already added via addAnotherType, don't duplicate
            } else {
                viewModel.config.problems.append(currentProblemConfig)
            }
        }
        viewModel.generate()
    }
}
