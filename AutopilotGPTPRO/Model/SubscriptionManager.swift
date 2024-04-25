import StoreKit

class SubscriptionManager {
    static let shared = SubscriptionManager()
    
    var products: [Product] = []
    
    init() {
        fetchAvailableSubscriptions { result in
            switch result {
                case .success(let products):
                    self.products = products
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
                    
            case .unverified(let transaction, let verificationError):
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
                        completion(.success(transaction))
                    case .unverified(_, let error):
                            completion(.failure(error))
                    }
                case .pending:
                    print("Purchase is pending")
                case .userCancelled:
                    print("User cancelled the purchase")
                @unknown default:
                    print("Unknown purchase result")
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}
