import SwiftUI

struct LicenseView: View {
    var body: some View {
        ScrollView {
            Text("license_text")
                .font(.footnote.monospaced())
                .padding()
        }
        .navigationTitle("settings_license")
        .navigationBarTitleDisplayMode(.inline)
    }
}
