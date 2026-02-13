import SwiftUI

struct WizardStepPageSettingsView: View {
    @Binding var worksheetConfig: WorksheetConfig
    @Binding var paywallFeature: ProFeature?
    let storeManager = StoreManager.shared

    var body: some View {
        Form {
            Section {
                Text("wizard_page_settings_prompt")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section {
                Stepper("pages_label \(worksheetConfig.numberOfPages)",
                        value: Binding(
                            get: { worksheetConfig.numberOfPages },
                            set: { newValue in
                                if newValue > 3 && !storeManager.isProUnlocked {
                                    paywallFeature = .extendedPages
                                    return
                                }
                                worksheetConfig.numberOfPages = newValue
                            }
                        ),
                        in: 1...100)

                Stepper("start_page_label \(worksheetConfig.pageOffset)",
                        value: $worksheetConfig.pageOffset,
                        in: 1...1000)
            }

            Section {
                if storeManager.isProUnlocked {
                    TextField("child_name_label", text: $worksheetConfig.childName)
                    TextField("school_name_label", text: $worksheetConfig.schoolName)
                } else {
                    Button {
                        paywallFeature = .customHeader
                    } label: {
                        HStack {
                            Label("custom_header_label", systemImage: "person.text.rectangle")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section {
                if storeManager.isProUnlocked {
                    Toggle("include_answer_key", isOn: $worksheetConfig.includeAnswerKey)
                } else {
                    Button {
                        paywallFeature = .answerKey
                    } label: {
                        HStack {
                            Label("include_answer_key", systemImage: "checkmark.circle")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
}
