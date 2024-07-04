
import UIKit
import Adapty
import Combine

class PurchasesObserver: ObservableObject {
    static let shared = PurchasesObserver()
    
    
    @Published var profile: AdaptyProfile?
    
    /*
     
     (
     profileId: 82149a4d-3cd4-45aa-80b3-cf65fa84abc5,
     segmentId: ef46db3751d8e999, 
     customAttributes: [:],
     accessLevels:
         ["monthly access": 
            (
            id: monthly access,
            isActive: true,
            vendorProductId: com.interview.ai.buddy.monthly,
            store: app_store,
            activatedAt: 2024-05-19 03:15:41 +0000,
            renewedAt: 2024-05-19 03:21:40 +0000,
            expiresAt: 2024-05-19 03:24:40 +0000,
            isLifetime: false,
            willRenew: true,
            isInGracePeriod: false,
            isRefund: false
            )
         ],
     subscriptions: 
        ["com.interview.ai.buddy.monthly": 
            (
            isActive: true,
            vendorProductId: com.interview.ai.buddy.monthly,
            store: app_store,
            activatedAt: 2024-05-19 03:15:41 +0000, 
            renewedAt: 2024-05-19 03:21:40 +0000,
            expiresAt: 2024-05-19 03:24:40 +0000,
            isLifetime: false, willRenew: true,
            isInGracePeriod: false,
            isSandbox: true,
            vendorTransactionId: 2000000602825530,
            vendorOriginalTransactionId: 2000000602824627,
            isRefund: false
            )
        ],
     nonSubscriptions: [:]
    )
     
     */
    
    
    @Published var subscriptionIsActive: Bool = false
    @Published var products: [AdaptyPaywallProduct]?
    @Published var introEligibilities: [String: AdaptyEligibility]?

    @Published var paywall: AdaptyPaywall? {
        didSet {
            loadPaywallProducts()
        }
    }
    
    private init() {
        
    }

    func loadInitialProfileData() {
        Adapty.getProfile { [weak self] result in
            self?.profile = try? result.get()
        }
    }

    func loadInitialPaywallData() {
        paywall = nil
        products = nil

        Adapty.getPaywall(placementId: AppConstants.examplePaywallId,
                          locale: "en") { [weak self] result in
            self?.paywall = try? result.get()
        }
    }

    private func loadPaywallProducts() {
        guard let paywall = paywall else { return }

        Adapty.getPaywallProducts(paywall: paywall) { [weak self] result in
            guard let products = try? result.get() else { return }

            self?.products = products
            self?.loadIntroductoryOfferEligibilities(products)
        }
    }

    private func loadIntroductoryOfferEligibilities(_ products: [AdaptyPaywallProduct]) {
        Adapty.getProductsIntroductoryOfferEligibility(products: products) { [weak self] result in
            self?.introEligibilities = try? result.get()
        }
    }

    func makePurchase(_ product: AdaptyPaywallProduct, completion: @escaping (Result<AdaptyProfile, Error>) -> Void) {
        
        Adapty.makePurchase(product: product) { [weak self] result in
            switch result {
            case let .success(purchasedResult):
                self?.profile = purchasedResult.profile
                    completion(.success(purchasedResult.profile))
            case let .failure(error):
                    completion(.failure(error as Error))
            }
        }
    }

    func restore(completion: ((AdaptyError?) -> Void)?) {
        Adapty.restorePurchases { [weak self] result in
            switch result {
            case let .success(profile):
                self?.profile = profile
                completion?(nil)
            case let .failure(error):
                completion?(error)
            }
        }
    }
    
    private func handleProfileUpdate(_ profile: AdaptyProfile) {
        self.profile = profile
        // Check the status of the subscription
        if let subscription = profile.subscriptions[AppConstants.monthlySubscriptonId] {
            if !subscription.isActive {
                // Subscription is no longer active, handle the refund case
                self.subscriptionIsActive = false
                print("Subscription is NOT active!")
            } else {
                // Subscription is active, update your app state accordingly
                self.subscriptionIsActive = true
                print("Subscription is active!")
                print("Expires at: \(subscription.expiresAt!)")
            }
        }
//        if let subscription = profile.subscriptions[AppConstants.monthlySubscriptonId],
//           !subscription.isActive {
//            // Subscription is no longer active, handle the refund case
//            self.subscriptionIsActive = false
//            print("Subscription is NOT active!")
//        } else {
//            // Subscription is active, update your app state accordingly
//            self.subscriptionIsActive = true
//            print("Subscription is active!")
//        }
    }
    
}

extension PurchasesObserver: AdaptyDelegate {
    
    func didLoadLatestProfile(_ profile: AdaptyProfile) {
//        self.profile = profile
//        print("Subscription state loaded: \(profile)")
        handleProfileUpdate(profile)
    }
}
