import SwiftUI
import SwiftData
import StoreKit

struct SettingsView: View {
    @AppStorage("appLanguage") private var appLanguage = "ko"
    @Environment(\.modelContext) private var modelContext
    @State private var showPaywall = false
    @State private var showDeleteWorksheetsAlert = false
    @State private var showDeletePresetsAlert = false
    private let storeManager = StoreManager.shared

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - General
                Section("settings_general") {
                    Picker("settings_language", selection: $appLanguage) {
                        Text("한국어").tag("ko")
                        Text("English").tag("en")
                        Text("Deutsch").tag("de")
                    }

                    NavigationLink {
                        HowToUseView()
                    } label: {
                        Label("settings_how_to_use", systemImage: "questionmark.circle")
                    }
                }

                // MARK: - Pro
                Section("settings_pro") {
                    if !storeManager.isProUnlocked {
                        Button {
                            showPaywall = true
                        } label: {
                            HStack {
                                Label("settings_upgrade_pro", systemImage: "star.circle.fill")
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Button {
                        Task { await storeManager.restore() }
                    } label: {
                        Label("restore_purchases", systemImage: "arrow.clockwise")
                    }
                }

                // MARK: - Data Management
                Section("settings_data") {
                    Button(role: .destructive) {
                        showDeleteWorksheetsAlert = true
                    } label: {
                        Label("settings_delete_all_worksheets", systemImage: "trash")
                    }

                    Button(role: .destructive) {
                        showDeletePresetsAlert = true
                    } label: {
                        Label("settings_delete_all_presets", systemImage: "trash")
                    }
                }

                #if DEBUG
                Section("Debug") {
                    Toggle("Pro Unlocked", isOn: Binding(
                        get: { storeManager.isProUnlocked },
                        set: { newValue in
                            storeManager.isProUnlocked = newValue
                            UserDefaults.standard.set(newValue, forKey: "debugProUnlocked")
                        }
                    ))
                }
                #endif

                // MARK: - About
                Section("settings_about") {
                    HStack {
                        Label("settings_version", systemImage: "info.circle")
                        Spacer()
                        Text(Bundle.main.appVersionString)
                            .foregroundStyle(.secondary)
                    }

                    Button {
                        requestReview()
                    } label: {
                        Label("settings_rate_app", systemImage: "star")
                            .foregroundStyle(.primary)
                    }

                    Button {
                        sendFeedback()
                    } label: {
                        Label("settings_send_feedback", systemImage: "envelope")
                            .foregroundStyle(.primary)
                    }

                    NavigationLink {
                        LicenseView()
                    } label: {
                        Label("settings_license", systemImage: "doc.text")
                    }
                }
            }
            .navigationTitle("settings_tab")
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .alert("settings_delete_all_worksheets", isPresented: $showDeleteWorksheetsAlert) {
                Button("delete", role: .destructive) {
                    try? modelContext.delete(model: WorksheetRecord.self)
                }
                Button("cancel", role: .cancel) {}
            } message: {
                Text("delete_confirm_worksheets")
            }
            .alert("settings_delete_all_presets", isPresented: $showDeletePresetsAlert) {
                Button("delete", role: .destructive) {
                    try? modelContext.delete(model: Preset.self)
                }
                Button("cancel", role: .cancel) {}
            } message: {
                Text("delete_confirm_presets")
            }
        }
    }

    private func requestReview() {
        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }
        SKStoreReviewController.requestReview(in: scene)
    }

    private func sendFeedback() {
        let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "ko"
        let subject = String(localized: "feedback_subject", locale: Locale(identifier: lang))
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "mailto:haebom.dev@gmail.com?subject=\(encodedSubject)") {
            UIApplication.shared.open(url)
        }
    }
}

extension Bundle {
    var appVersionString: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}
