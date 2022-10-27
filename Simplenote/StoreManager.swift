//
//  StoreManager.swift
//  Simplenote
//
//  Created by Jorge Leandro Perez on 10/26/22.
//  Copyright © 2022 Automattic. All rights reserved.
//

import Foundation
import StoreKit


// MARK: - StoreError
//
enum StoreError: Error {
    case failedVerification
}


// MARK: - StoreManager
//
@available(iOS 15, *)
class StoreManager {

    // MARK: - Static
    //
    static let shared = StoreManager()


    // MARK: - Aliases
    //
    typealias RenewalState = Product.SubscriptionInfo.RenewalState


    // MARK: - Private Properties

    private(set) var subscriptions: [StoreProduct: Product] = [:]
    private(set) var purchasedSubscriptions: [Product] = []
    private(set) var subscriptionGroupStatus: RenewalState?


    // MARK: - Public Properties

    private var updateListenerTask: Task<Void, Error>?


    deinit {
        updateListenerTask?.cancel()
    }


    // MARK: - Public API(s)

    /// Initialization involves three major steps:
    ///
    ///     1.  Listen for Pending Transactions
    ///     2.  Request the Known Products
    ///     3.  Refresh the Purchased Products (and update Core Data)
    ///
    /// This API should be invoked shortly after the Launch Sequence is complete.
    ///
    func initialize() {
        NSLog("[StoreManager] Initializing...")

        updateListenerTask = listenForTransactions()

        Task {
            await refreshKnownProducts()
            await refreshPurchasedProducts()
        }
    }


    /// Purchases the specified Product
    ///
    func purchase(product: StoreProduct) {
        guard let subcription = subscriptions[product] else {
            return
        }

        Task {
            do {
                try await purchase(product: subcription)
            } catch {
                NSLog("[StoreManager] Purchase Failed \(error)")
            }
        }
    }
}


// MARK: - Private API(s)
//
@available(iOS 15, *)
private extension StoreManager {

    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.refreshPurchasedProducts()
                    await transaction.finish()

                } catch {
                    NSLog("[StoreKit] Transaction failed verification. Error \(error)")
                }
            }
        }
    }

    @MainActor
    func refreshKnownProducts() async {
        do {
            let allProducts = try await Product.products(for: StoreProduct.allIdentifiers)
            let subscriptionProducts = filter(products: allProducts, ofType: .autoRenewable)

            subscriptions = self.buildSubscriptionsMap(products: subscriptionProducts)

            NSLog("[StoreKit] Retrieved \(subscriptions.count) Subscription Products")

        } catch {
            NSLog("[StoreKit] Failed product request from the App Store server: \(error)")
        }
    }

    @MainActor
    func refreshPurchasedProducts() async {
        var newPurchasedSubscriptions: [Product] = []

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                switch transaction.productType {
                case .autoRenewable:
                    if let subscription = subscriptions.values.first(where: { $0.id == transaction.productID }) {
                        newPurchasedSubscriptions.append(subscription)
                    }
                default:
                    break
                }
            } catch {
                NSLog("[StoreKit] Failed to refresh Current Entitlements: \(error)")
            }
        }

        purchasedSubscriptions = newPurchasedSubscriptions

        // Check the `subscriptionGroupStatus` to learn the auto-renewable subscription state to determine whether the customer
        // is new (never subscribed), active, or inactive (expired subscription). This app has only one subscription
        // group, so products in the subscriptions array all belong to the same group. The statuses that
        // `product.subscription.status` returns apply to the entire subscription group.
        subscriptionGroupStatus = try? await subscriptions.values.first?.subscription?.status.first?.state
    }

    @discardableResult
    func purchase(product: Product) async throws -> Transaction? {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)

            await refreshPurchasedProducts()
            await transaction.finish()

            return transaction

        case .userCancelled, .pending:
            return nil
        default:
            return nil
        }
    }
}



// MARK: - Private Helpers
//
@available(iOS 15, *)
private extension StoreManager {

    func filter(products: [Product], ofType type: Product.ProductType) -> [Product] {
        var newSubscriptions: [Product] = []

        for product in products {
            switch product.type {
            case .autoRenewable:
                newSubscriptions.append(product)
            default:
                NSLog("[StoreManager] Unknown product: \(product)")
            }
        }

        return newSubscriptions
    }

    func buildSubscriptionsMap(products: [Product]) -> [StoreProduct: Product] {
        return products.reduce([StoreProduct: Product]()) { partialResult, product in
            var updated = partialResult
            if let storeProduct = self.findStoreProduct(for: product) {
                updated[storeProduct] = product
            }

            return updated
        }
    }

    func findStoreProduct(for product: Product) -> StoreProduct? {
        StoreProduct.allCases.first { storeProduct in
            product.id == storeProduct.identifier
        }
    }

    func isPurchased(_ product: Product) async throws -> Bool {
        switch product.type {
        case .autoRenewable:
            return purchasedSubscriptions.contains(product)
        default:
            return false
        }
    }

    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}
