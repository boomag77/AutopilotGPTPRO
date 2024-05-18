
import Adapty
import UIKit

class AdaptyManager {
    
    
    var paywall: AdaptyPaywall?
    var products: [AdaptyPaywallProduct]?
    
    init() {
        //Adapty.activate("public_live_eitcXPrT.V7zWesNyCbnYWxtbU4E6")
        Adapty.delegate = self
        loadPaywall()
    }
    
    
    func loadPaywall() {
        
        Adapty.getPaywall(placementId: "start_session", locale: "en") { [weak self] result in
            switch result {
                case let .success(paywall):
                    // the requested paywall
                self?.paywall = paywall
                self?.loadPaywallProducts()
                case let .failure(error):
                ErrorHandler.showAlert(title: "AdaptyManager Error",
                                    message: "func loadPaywall: Error fetching paywall: \(error.localizedDescription)")
            }
        }
    }
    
    func loadPaywallProducts() {
        
        guard let paywall = self.paywall else {
            print("Paywall must be loaded before loading products")
            return
        }

        Adapty.getPaywallProducts(paywall: paywall) { [weak self] result in
            switch result {
            case let .success(products):
                self?.products = products
                print("Products loaded: \(products.count)")
                print("Products: \(products)")
            case let .failure(error):
                    ErrorHandler.showAlert(title: "AdaptyManager Error",
                                           message: "func loadPaywallProducts: Error fetching products: \(error.localizedDescription)")
            }
        }
    }
    
    private func logShowPaywall(paywall: AdaptyPaywall) {
        Adapty.logShowPaywall(paywall)
    }
    
//    func makePurchase(product: AdaptyPaywallProduct, completion: @escaping (Result<Error>?) -> Void) {
//        
//        Adapty.makePurchase(product: product) { result in
//            switch result {
//            case let .success(info):
//                if let access = info.profile.accessLevels["monthly"]?.isActive {
//                    // grant access to premium features
//                    //AppDelegate.isSubscriptionActive = access
//                    completion(nil)
//                }
//            case let .failure(error):
//                print("Adapty Manager -> Purchase error: \(error.localizedDescription)")
//                completion(error)
//            }
//        }
//    }
    
    func checkAccess(completion: @escaping (Bool) -> Void) {
        
        Adapty.getProfile { result in
            
            switch result {
            case let .success(profile):
                
                guard let accessLevel = profile.accessLevels["monthly"] else {
                    return
                }
                completion(accessLevel.isActive ? true : false)
            case let .failure(error):
//                let errorText = "Error fetching profile: \(error.localizedDescription)"
//                self?.throwError(errorText)
                    ErrorHandler.showAlert(title: "AdaptyManager Error", message: "func checkAccess: Error fetching profile: \(error.localizedDescription)")
                //print("Error fetching profile: \(error.localizedDescription)")
            }
        }
    }
    
    func restorePurchases() {
//        Adapty.restorePurchases { [weak self] result in
//            switch result {
//                case let .success(profile):
//                    if info.profile.accessLevels["YOUR_ACCESS_LEVEL"]?.isActive ?? false {
//                        // successful access restore
//                    }
//                case let .failure(error):
//                    // handle the error
//            }
//        }
    }
}

extension AdaptyManager: AdaptyDelegate {
    func didLoadLatestProfile(_ profile: AdaptyProfile) {
        // handle any changes to subscription state
        print("Delegate - \(profile)")
    }
}
