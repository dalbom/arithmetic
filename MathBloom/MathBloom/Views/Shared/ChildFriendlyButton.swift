import SwiftUI

struct ChildFriendlyButton: View {
    let title: LocalizedStringKey
    let systemImage: String
    let color: Color
    let action: () -> Void

    init(_ title: LocalizedStringKey, systemImage: String = "", color: Color = .blue, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.color = color
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if !systemImage.isEmpty {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(color.gradient)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .sensoryFeedback(.impact, trigger: UUID())
    }
}
