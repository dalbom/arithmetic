import StoreKit
import SwiftUI

@Observable
final class StoreManager {
    static let shared = StoreManager()

    private let productID = "com.haebom.mathbloom.pro"

    #if DEBUG
    var isProUnlocked: Bool = UserDefaults.standard.bool(forKey: "debugProUnlocked")
    #else
    var isProUnlocked: Bool = false
    #endif
    var product: Product?
    var purchaseError: String?
    var isLoading: Bool = false

    private var transactionListener: Task<Void, Error>?

    init() {
        transactionListener = listenForTransactions()
        Task {
            await loadProduct()
            await checkEntitlement()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    /// Load the Pro product from the App Store
    func loadProduct() async {
        do {
            let products = try await Product.products(for: [productID])
            product = products.first
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    /// Purchase the Pro upgrade
    private var appLocale: Locale {
        Locale(identifier: UserDefaults.standard.string(forKey: "appLanguage") ?? "ko")
    }

    func purchase() async {
        guard let product else {
            purchaseError = String(localized: "store_product_unavailable", locale: appLocale)
            return
        }

        isLoading = true
        purchaseError = nil

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                isProUnlocked = true
                await transaction.finish()
            case .userCancelled:
                break
            case .pending:
                purchaseError = String(localized: "store_purchase_pending", locale: appLocale)
            @unknown default:
                break
            }
        } catch {
            purchaseError = error.localizedDescription
        }

        isLoading = false
    }

    /// Restore previous purchases
    func restore() async {
        isLoading = true
        try? await AppStore.sync()
        await checkEntitlement()
        isLoading = false
    }

    /// Check if user has Pro entitlement
    func checkEntitlement() async {
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result),
               transaction.productID == productID {
                isProUnlocked = true
                return
            }
        }
    }

    /// Check if a specific Pro feature is available
    func isFeatureUnlocked(_ feature: ProFeature) -> Bool {
        isProUnlocked
    }

    // MARK: - Limits for free tier

    var maxDigits: Int { isProUnlocked ? 5 : 2 }
    var maxOperands: Int { isProUnlocked ? 5 : 2 }
    var maxPages: Int { isProUnlocked ? 100 : 3 }
    var maxPresets: Int { isProUnlocked ? .max : 2 }

    // MARK: - Private

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                if let transaction = try? self.checkVerified(result),
                   transaction.productID == self.productID {
                    self.isProUnlocked = true
                    await transaction.finish()
                }
            }
        }
    }
}
