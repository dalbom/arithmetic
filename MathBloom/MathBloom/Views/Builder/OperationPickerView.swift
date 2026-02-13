import SwiftUI

struct OperationPickerView: View {
    @Binding var selectedType: OperationType
    let storeManager = StoreManager.shared
    @State private var paywallFeature: ProFeature?

    var body: some View {
        HStack(spacing: 10) {
            ForEach(OperationType.allCases) { operation in
                Button {
                    if operation.requiresPro && !storeManager.isProUnlocked {
                        paywallFeature = operation == .multiplication ? .multiplication : .division
                    } else {
                        selectedType = operation
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(operation.symbol)
                            .font(.title3)
                        Text(operation.localizedName)
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        selectedType == operation
                            ? Color.accentColor
                            : Color(.systemGray5)
                    )
                    .foregroundStyle(selectedType == operation ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .sheet(item: $paywallFeature) { feature in
            PaywallView(triggeredFeature: feature)
        }
    }
}
