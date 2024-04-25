
import Adapty
//import AdaptyUI
import UIKit

protocol AdaptyManagerDelegateProtocol {
    func handleError(errorTitle: String, errorDescription: String)
    func setSubscriptionStatus(_ status: Bool)
}

class AdaptyManager {
    
    static let shared = AdaptyManager()
    
    var viewController: AdaptyManagerDelegateProtocol?
    let errorTitle: String = "Adapty Error"
    
    var paywall: AdaptyPaywall?
    var products: [AdaptyPaywallProduct]?
    
    init() {
        loadPaywall()
        //loadPaywallProducts()
    }
    
    
    func loadPaywall() {
        Adapty.getPaywall(placementId: "start_session") { [weak self] result in
            switch result {
                case let .success(paywall):
                    // the requested paywall
                self?.paywall = paywall
                self?.loadPaywallProducts()
                
                case let .failure(error):
                print("Error fetching paywall: \(error.localizedDescription)")
            }
        }
    }
    
//    func getPaywallProducts(paywall: AdaptyPaywall) -> [AdaptyPaywallProduct]? {
//        var requestedProducts: [AdaptyPaywallProduct]?
//        Adapty.getPaywallProducts(paywall: paywall) { result in
//            switch result {
//            case let .success(products):
//                requestedProducts = products
//                print("Products loaded: \(products.count)")
//            case let .failure(error):
//                print("Error fetching products: \(error.localizedDescription)")
//            }
//        }
//        return requestedProducts
//    }
    
    private func throwError(_ error: AdaptyError) {
        viewController?.handleError(errorTitle: "Adapty Error", errorDescription: error.localizedDescription)
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
            case let .failure(error):
                self?.throwError(error)
                print("Error fetching products: \(error.localizedDescription)")
            }
        }
    }
    
//    func isAligibleToOffer() {
//        guard let products = self.products else {
//            return
//        }
//        Adapty.getProductsIntroductoryOfferEligibility(products: products) { result in
//            switch result {
//                case .success(let eligibilities):
//                    // update your UI
//                print(eligibilities)
//                case let .failure(error):
//                print("Error gettig eligibiliy: \(error.localizedDescription)")
//            }
//        }
//    }
    func fetchAdditionalPaywallInfo() {
        Adapty.getPaywall(placementId: "start_session") { [weak self] result in
            switch result {
            case let .success(paywall):
                let headerText = paywall.remoteConfig?["header_text"] as? String
                print("Header Text: \(headerText ?? "No header text available")")
            case let .failure(error):
                self?.throwError(error)
                print("Error fetching additional paywall info: \(error.localizedDescription)")
            }
        }
    }
    
    private func logShowPaywall(paywall: AdaptyPaywall) {
        Adapty.logShowPaywall(paywall)
    }
    
    func makePurchase(product: AdaptyProduct, from viewController: UIViewController) {
//        self.viewController?.setSubscriptionStatus(true)
//        viewController.dismiss(animated: true)
        Adapty.makePurchase(product: product as! AdaptyPaywallProduct) { [weak self] result in
            switch result {
            case let .success(info):
                if info.profile.accessLevels["premium"]?.isActive ?? false {
                    // grant access to premium features
                    viewController.dismiss(animated: false)
                    self?.viewController?.setSubscriptionStatus(true)
                }
            case let .failure(error):
                viewController.dismiss(animated: false)
                self?.throwError(error)
                print("Purchase error: \(error.localizedDescription)")
                return
            }
        }
    }
    
    func checkAccess(completion: @escaping (Bool) -> Void) {
        
        Adapty.getProfile { [weak self] result in
            switch result {
            case let .success(profile):
                guard let accessLevel = profile.accessLevels["premium"] else {
                    return
                }
                if accessLevel.isActive {
                    // User has an active "premium" subscription
                    completion(true)
                    print("Subscription is valid!")
                } else {
                    // User does not have an active "premium" subscription
                    completion(false)
                    print("Subscription is not valid.")
                }
            case let .failure(error):
                self?.throwError(error)
                print("Error fetching profile: \(error.localizedDescription)")
            }
        }
    }
}
