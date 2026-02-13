import SwiftUI

struct HowToUseView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: - 만들기 탭
                GroupBox {
                    VStack(alignment: .leading, spacing: 16) {
                        Label("howto_create_title", systemImage: "plus.rectangle.fill")
                            .font(.headline)
                            .foregroundStyle(.blue)

                        Text("howto_create_intro")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Divider()

                        // Step 1: Operation
                        howtoItem(
                            step: "1",
                            icon: "plus.forwardslash.minus",
                            color: .green,
                            title: "howto_create_step1_title",
                            description: "howto_create_step1_desc"
                        )

                        // Step 2: Operands
                        howtoItem(
                            step: "2",
                            icon: "number",
                            color: .orange,
                            title: "howto_create_step2_title",
                            description: "howto_create_step2_desc"
                        )

                        // Step 3: Options
                        howtoItem(
                            step: "3",
                            icon: "slider.horizontal.3",
                            color: .purple,
                            title: "howto_create_step3_title",
                            description: "howto_create_step3_desc"
                        )

                        // Step 4: Page Settings
                        howtoItem(
                            step: "4",
                            icon: "doc.on.doc",
                            color: .indigo,
                            title: "howto_create_step4_title",
                            description: "howto_create_step4_desc"
                        )

                        // Step 5: Review & Generate
                        howtoItem(
                            step: "5",
                            icon: "checkmark.circle",
                            color: .blue,
                            title: "howto_create_step5_title",
                            description: "howto_create_step5_desc"
                        )
                    }
                }

                // MARK: - 기록 탭
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("howto_records_title", systemImage: "clock.fill")
                            .font(.headline)
                            .foregroundStyle(.blue)

                        Text("howto_records_desc")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // MARK: - 설정 탭
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("howto_settings_title", systemImage: "gearshape.fill")
                            .font(.headline)
                            .foregroundStyle(.blue)

                        Text("howto_settings_desc")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
        }
        .navigationTitle("settings_how_to_use")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func howtoItem(
        step: String,
        icon: String,
        color: Color,
        title: LocalizedStringKey,
        description: LocalizedStringKey
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.gradient)
                    .frame(width: 28, height: 28)
                Text(step)
                    .font(.caption.bold())
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .foregroundStyle(color)
                    Text(title)
                        .font(.subheadline.bold())
                }
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
