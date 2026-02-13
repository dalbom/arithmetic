import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    let storeManager = StoreManager.shared
    let triggeredFeature: ProFeature?

    init(triggeredFeature: ProFeature? = nil) {
        self.triggeredFeature = triggeredFeature
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.yellow)

                        Text("mathbloom_pro_title")
                            .font(.largeTitle.bold())

                        Text("mathbloom_pro_subtitle")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)

                    // Highlighted feature if triggered from a specific lock
                    if let feature = triggeredFeature {
                        HStack {
                            Image(systemName: feature.iconName)
                                .font(.title2)
                                .foregroundStyle(.blue)
                            VStack(alignment: .leading) {
                                Text(feature.localizedName)
                                    .font(.headline)
                                Text(feature.localizedDescription)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    }

                    // Feature list
                    VStack(alignment: .leading, spacing: 12) {
                        Text("pro_features_header")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(ProFeature.allCases) { feature in
                            HStack(spacing: 12) {
                                Image(systemName: feature.iconName)
                                    .frame(width: 24)
                                    .foregroundStyle(.blue)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(feature.localizedName)
                                        .font(.subheadline.weight(.medium))
                                    Text(feature.localizedDescription)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)

                    // Purchase button
                    VStack(spacing: 12) {
                        if let product = storeManager.product {
                            Button {
                                Task { await storeManager.purchase() }
                            } label: {
                                HStack {
                                    if storeManager.isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    }
                                    Text("purchase_button \(product.displayPrice)")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .disabled(storeManager.isLoading)
                        } else {
                            ProgressView()
                        }

                        Button {
                            Task { await storeManager.restore() }
                        } label: {
                            Text("restore_purchases")
                                .font(.subheadline)
                                .foregroundStyle(.blue)
                        }

                        if let error = storeManager.purchaseError {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onChange(of: storeManager.isProUnlocked) { _, newValue in
                if newValue { dismiss() }
            }
        }
    }
}
