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
    typealias SubscriptionStatus = Product.SubscriptionInfo.Status


    // MARK: - Private Properties

    private(set) var subscriptions: [StoreProduct: Product] = [:]
    private(set) var purchasedSubscriptions: [Product] = []
    private(set) var subscriptionGroupStatus: SubscriptionStatus?


    // MARK: - Calculated Properties

    private var subscriptionProducts: [Product] {
        Array(subscriptions.values)
    }


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
    ///     4.  Refresh the SubscriptionGroup Status
    ///
    /// This API should be invoked shortly after the Launch Sequence is complete.
    ///
    func initialize() {
        NSLog("[StoreManager] Initializing...")

        updateListenerTask = listenForTransactions()

        Task {
            await refreshKnownProducts()
            await refreshPurchasedProducts()
            await refreshSubscriptionGroupStatus()
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
                    await self.refreshSubscriptionGroupStatus()
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

    /// - Note:
    ///     The `purchasedSubscriptions` collection us determine if a given `Product` instance has been purchased, or not
    ///
    @MainActor
    func refreshPurchasedProducts() async {
        var newPurchasedSubscriptions: [Product] = []

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                switch transaction.productType {
                case .autoRenewable:
                    if let subscription = subscriptionProducts.first(where: { $0.id == transaction.productID }) {
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
    }

    /// - Important!
    ///     Simplenote has a single Subscription Group. `product.subscription.status` represents the entire subscription group status
    @MainActor
    func refreshSubscriptionGroupStatus() async {
        do {
            subscriptionGroupStatus = try await subscriptionProducts.first?.subscription?.status.first
        } catch {
            NSLog("[StoreKit] Failed to refresh the Subscription Group Status: \(error)")
        }
    }

    @discardableResult
    func purchase(product: Product) async throws -> Transaction? {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)

            await refreshPurchasedProducts()
            await refreshSubscriptionGroupStatus()
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
