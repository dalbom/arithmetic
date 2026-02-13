import SwiftUI

struct ContentView: View {
    @AppStorage("appLanguage") private var appLanguage = "ko"
    @State private var selectedTab = 0
    @State private var builderViewModel = WorksheetBuilderViewModel()

    var body: some View {
        TabView(selection: $selectedTab) {
            WorksheetBuilderView(viewModel: builderViewModel)
                .tabItem {
                    Label("create_tab", systemImage: "plus.rectangle.fill")
                }
                .tag(0)

            RecordsView(
                onEditPreset: { config in
                    builderViewModel.loadConfig(config)
                    selectedTab = 0
                },
                onGenerateFromPreset: { config in
                    builderViewModel.loadConfig(config)
                    builderViewModel.generate()
                    selectedTab = 0
                }
            )
            .tabItem {
                Label("records_tab", systemImage: "clock.fill")
            }
            .tag(1)

            SettingsView()
                .tabItem {
                    Label("settings_tab", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .tint(.blue)
        .environment(\.locale, Locale(identifier: appLanguage))
    }
}
