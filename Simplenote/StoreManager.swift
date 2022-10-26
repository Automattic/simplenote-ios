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

    private(set) var subscriptions: [Product] = []
    private(set) var purchasedSubscriptions: [Product] = []
    private(set) var subscriptionGroupStatus: RenewalState?


    // MARK: - Public Properties

    private var updateListenerTask: Task<Void, Error>?


    // MARK: - Public API(s)

    /// Initialization:
    /// - Starts listening for Pending Transactions
    /// - Requests the Available Products
    ///
    func initialize() {
        NSLog("[StoreManager] Initializing...")

        updateListenerTask = listenForTransactions()
        refreshSubscriptionProducts()
    }


    ///
    ///
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            //Check whether the transaction is verified. If it isn't,
            //this function rethrows the verification error.
            let transaction = try checkVerified(verification)

            await refreshSubscriptionStatus()

            await transaction.finish()

            return transaction
        case .userCancelled, .pending:
            return nil
        default:
            return nil
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

                    await self.refreshSubscriptionStatus()

                    await transaction.finish()
                } catch {
                    NSLog("[StoreKit] Transaction failed verification. Error \(error)")
                }
            }
        }
    }

    func refreshSubscriptionProducts() {
        Task { @MainActor in
            do {
                let storeProducts = try await Product.products(for: StoreProduct.allIdentifiers)
                subscriptions = filter(products: storeProducts, ofType: .autoRenewable)
            } catch {
                NSLog("Failed product request from the App Store server: \(error)")
            }
        }
    }

    @MainActor
    func refreshSubscriptionStatus() async {
        var newPurchasedSubscriptions: [Product] = []

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                switch transaction.productType {
                case .autoRenewable:
                    if let subscription = subscriptions.first(where: { $0.id == transaction.productID }) {
                        newPurchasedSubscriptions.append(subscription)
                    }
                default:
                    break
                }
            } catch {
                print()
            }
        }

        purchasedSubscriptions = newPurchasedSubscriptions

        // Check the `subscriptionGroupStatus` to learn the auto-renewable subscription state to determine whether the customer
        // is new (never subscribed), active, or inactive (expired subscription). This app has only one subscription
        // group, so products in the subscriptions array all belong to the same group. The statuses that
        // `product.subscription.status` returns apply to the entire subscription group.
        subscriptionGroupStatus = try? await subscriptions.first?.subscription?.status.first?.state
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
