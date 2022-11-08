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
    typealias RenewalInfo = Product.SubscriptionInfo.RenewalInfo

    // MARK: - Private Properties

    private var updateListenerTask: Task<Void, Error>?
    private(set) var storeProductMap: [StoreProduct: Product] = [:]
    private(set) var purchasedProducts: [Product] = []
    private(set) var subscriptionGroupStatus: SubscriptionStatus? {
        didSet {
            refreshSimperiumPreferences(status: subscriptionGroupStatus)
        }
    }

    // MARK: - Public Properties

    var isActiveSubscriber: Bool {
        guard let subscriptionGroupStatus else {
            return false
        }

        return subscriptionGroupStatus.isActive
    }


    // MARK: - Deinit

    deinit {
        updateListenerTask?.cancel()
    }


    // MARK: - Public API(s)

    /// Initialization involves three major steps:
    ///
    ///     1.  Listen for Pending Transactions
    ///     2.  Request the Known Products
    ///     3.  Refresh the Purchased Products
    ///     4.  Refresh the SubscriptionGroup Status (and update Core Data / refresh UI all over!)
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


    /// Purchases the specified Product (as long as we don't own it already?)
    ///
    func purchase(storeProduct: StoreProduct) {
        guard let product = storeProductMap[storeProduct], isActiveSubscriber == false else {
            return
        }

        Task {
            do {
                try await purchase(product: product)
                await SPTracker.trackSustainerPurchaseCompleted(storeProduct: storeProduct)
            } catch {
                NSLog("[StoreManager] Purchase Failed \(error)")
            }
        }
    }

    /// Returns the Display Price for a given Product
    ///
    func displayPrice(for storeProduct: StoreProduct) -> String? {
        guard let product = storeProductMap[storeProduct] else {
            return nil
        }

        return product.displayPrice
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
            storeProductMap = self.buildStoreProductMap(products: allProducts)

            NSLog("[StoreKit] Retrieved \(storeProductMap.count) Subscription Products")

        } catch {
            NSLog("[StoreKit] Failed product request from the App Store server: \(error)")
        }
    }

    /// The `purchasedProducts` collection us determine if a given `Product` instance has been purchased, or not.
    ///
    @MainActor
    func refreshPurchasedProducts() async {
        var newPurchasedProducts: [Product] = []

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if let subscription = storeProductMap.values.first(where: { $0.id == transaction.productID }) {
                    newPurchasedProducts.append(subscription)
                }

            } catch {
                NSLog("[StoreKit] Failed to refresh Current Entitlements: \(error)")
            }
        }

        purchasedProducts = newPurchasedProducts
    }

    /// - Important: Simplenote has a single Subscription Group. `product.subscription.status` represents the entire subscription group status
    ///
    @MainActor
    func refreshSubscriptionGroupStatus() async {
        do {
            let newStatus = try await storeProductMap.values.first?.subscription?.status.first
            subscriptionGroupStatus = newStatus
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

    func buildStoreProductMap(products: [Product]) -> [StoreProduct: Product] {
        return products.reduce([StoreProduct: Product]()) { partialResult, product in
            guard let storeProduct = StoreProduct.findStoreProduct(identifier: product.id) else {
                return partialResult
            }

            var updated = partialResult
            updated[storeProduct] = product
            return updated
        }
    }

    func isPurchased(_ product: Product) -> Bool {
        purchasedProducts.contains(product)
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


// MARK: - Simperium Kung Fu
//
@available(iOS 15, *)
private extension StoreManager {

    func refreshSimperiumPreferences(status: SubscriptionStatus?) {
        let simperium = SPAppDelegate.shared().simperium

        simperium.managedObjectContext().perform {
            self.refreshSimperiumPreferences(simperium: simperium, status: status)
        }
    }

    func refreshSimperiumPreferences(simperium: Simperium, status: SubscriptionStatus?) {
        let preferences = simperium.preferencesObject()
        guard mustUpdatePreferences(preferences: preferences) else {
            return
        }

        if let status, status.isActive {
            preferences.subscription_level = subscriptionLevel(from: status)
            preferences.subscription_date = subscriptionDate(from: status)
            preferences.subscription_platform = StoreConstants.platform
        } else {
            preferences.subscription_date = nil
            preferences.subscription_level = nil
            preferences.subscription_platform = nil
        }

        simperium.save()
    }

    func mustUpdatePreferences(preferences: Preferences) -> Bool {
        guard let platform = preferences.subscription_platform else {
            return true
        }

        return platform.isEmpty || platform == StoreConstants.platform
    }

    func subscriptionDate(from status: SubscriptionStatus) -> Date? {
        do {
            return try checkVerified(status.transaction).purchaseDate
        } catch {
            NSLog("[StoreManager] Error Verifying Transaction")
            return nil
        }
    }

    func subscriptionLevel(from status: SubscriptionStatus) -> String? {
        guard status.isActive else {
            return nil
        }

        return StoreConstants.activeSubscriptionLevel
    }
}


// MARK: - SubscriptionStatus Helpers
//
@available(iOS 15, *)
private extension Product.SubscriptionInfo.Status {

    var isActive: Bool {
        state == .subscribed || state == .inGracePeriod
    }
}
