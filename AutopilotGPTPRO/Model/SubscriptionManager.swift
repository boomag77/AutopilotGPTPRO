import StoreKit
import Combine

@MainActor
class SubscriptionManager {
    
    static let shared = SubscriptionManager()
    var products: [Product] = []
    var hasActiveSubscription: Bool = false {
        didSet {
            print("Subscrioption Manager hasActive \(hasActiveSubscription)")
        }
    }
    
    private init() {
        fetchAvailableSubscriptions { result in
            switch result {
                case .success(let products):
                    self.products = products
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
        checkForActiveSubscription { result in
            switch result {
                case .success(let status):
                    self.hasActiveSubscription = status
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
       
    }

    // Fetch available subscriptions
    func fetchAvailableSubscriptions(completion: @escaping (Result<[Product], Error>) -> Void) {
        Task {
            do {
                // Specify the product IDs
                let productIDs: Set<String> = ["com.autopilot.monthly.access"]
                
                // Fetch products from the App Store
                let products = try await Product.products(for: productIDs)
                self.products = products
                completion(.success(products))
            } catch {
                print("Failed ")
                completion(.failure(error))
            }
        }
    }
    
    
    func checkForActiveSubscription(completion: @escaping (Result<Bool, Error>) -> Void) {
        
        Task {
            let productIDs: Set<String> = ["com.autopilot.monthly.access"]
            let product = try await Product.products(for: productIDs).first
            
            guard let verificationResult = await product?.currentEntitlement else {
                
                return
            }


            switch verificationResult {
            case .verified(let transaction):
                // Check the transaction and give the user access to purchased
                // content as appropriate.
                    if transaction.revocationDate == nil &&
                        (transaction.expirationDate ?? Date.distantPast) > Date() {
                        print("Subscription is valid")
                        completion(.success(true))
                    } else {
                        completion(.success(false))
                    }
                    
            case .unverified(_, let verificationError):
                // Handle unverified transactions based
                // on your business model.
                    completion(.failure(verificationError))
            }
        }
    }
    
    func purchase(_ product: Product, completion: @escaping (Result<Transaction, Error>) -> Void) {
        
        
        
        Task {
            do {
                let result = try await product.purchase()
                switch result {
                case .success(let verificationResult):
                    switch verificationResult {
                    case .verified(let transaction):
                        await transaction.finish()
                            self.hasActiveSubscription = true
                        completion(.success(transaction))
                    case .unverified(_, let error):
                        print("Unverified purchase. Might be jailbroken. Error: \(error.localizedDescription)")
                        break
                    }
                case .pending:
                    print("Purchase is pending")
                    break
                case .userCancelled:
                    print("User cancelled the purchase")
                    break
                @unknown default:
                    print("Failed to purchase the product!")
                    break
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func restorePurchases() async {
        do {
            try await AppStore.sync()
        } catch(let error) {
            print("Subscription Manager -> Failed restoring purchases \(error.localizedDescription).")
        }
    }
}
