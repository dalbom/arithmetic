import SwiftUI
import SwiftData

@main
struct MathBloomApp: App {
    @AppStorage("appLanguage") private var appLanguage = "ko"

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.locale, Locale(identifier: appLanguage))
        }
        .modelContainer(for: [Preset.self, WorksheetRecord.self])
    }
}
